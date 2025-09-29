# frozen_string_literal: true

require 'cgi'
require 'hashie'
require 'net/http'
require 'nokogiri'

module Openfoodfacts
  class Product < Hashie::Mash
    # disable_warnings
    # TODO: Add more locales
    LOCALE_WEBURL_PREFIXES = {
      'fr' => 'produit',
      'uk' => 'product',
      'us' => 'product',
      'world' => 'product'
    }.freeze

    class << self
      # Get product
      #
      def get(code, locale: DEFAULT_LOCALE)
        return unless code

        product_url = url(code, locale: locale)
        json = Openfoodfacts.http_get(product_url).read
        hash = JSON.parse(json)

        new(hash['product']) if !hash['status'].nil? && hash['status'] == 1
      end
      alias find get

      # Return product API URL
      #
      def url(code, locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        return unless code

        prefix = LOCALE_WEBURL_PREFIXES[locale]
        path = "api/v2/#{prefix}/#{code}.json"
        "https://#{locale}.#{domain}/#{path}"
      end

      # Search products
      #
      def search(terms, locale: DEFAULT_LOCALE, page: 1, page_size: 20, sort_by: 'unique_scans_n',
                 domain: DEFAULT_DOMAIN)
        terms = CGI.escape(terms)
        path = "cgi/search.pl?search_terms=#{terms}&json=1&page=#{page}&page_size=#{page_size}&sort_by=#{sort_by}"
        url = "https://#{locale}.#{domain}/#{path}"
        json = Openfoodfacts.http_get(url).read
        hash = JSON.parse(json)
        products = []
        hash['products'].each do |data|
          products << new(data)
        end
        products
      end
      alias where search

      def from_html_list(html, list_css_selector, code_from_link_regex, locale: 'world')
        dom = Nokogiri::HTML.fragment(html)
        dom.css(list_css_selector).filter_map do |product|
          attributes = {}

          # Look for product links with multiple patterns
          link = product.css('a[href*="/product/"], a[href*="/produit/"]').first
          link ||= product.css('a').first

          next unless link

          attributes['product_name'] = link.inner_text.strip
          href = link.attr('href')

          # Try multiple regex patterns for extracting product codes
          regexes = [
            code_from_link_regex,           # Original pattern
            %r{/product/(\d+)}i,            # /product/123456
            %r{/produit/(\d+)}i,            # /produit/123456 (French)
            %r{/(\d{8,})},                   # Any 8+ digit number
            %r{product[/=](\d+)}i,           # product=123456 or product/123456
            %r{code[/=](\d+)}i               # code=123456 or code/123456
          ]

          code = nil
          regexes.each do |regex|
            match = href[regex, 1]
            if match && match.length >= 8 # Product codes are typically 8+ digits
              code = match
              break
            end
          end

          next unless code

          attributes['_id'] = code
          attributes['code'] = code

          # Skip products without valid codes

          if (image = product.css('img').first) && (image_url = image.attr('src'))
            attributes['image_small_url'] = image_url
            attributes['lc'] = Locale.locale_from_link(image_url)
          end
          attributes['lc'] ||= locale

          new(attributes)
        end
      end

      def from_website_list(html, locale: 'world')
        # Try multiple CSS selectors to handle different page structures
        selectors = [
          'ul.products li',           # Original selector
          '.search_results article',  # Modern article-based structure
          '.search-results .result',  # Alternative modern structure
          'article',                  # Simple article tags
          '.product-item',           # Product item classes
          '.product',                # Simple product classes
          'li[data-product-code]'    # Data attribute based
        ]

        dom = Nokogiri::HTML.fragment(html)

        selectors.each do |selector|
          elements = dom.css(selector)
          next if elements.empty?

          # Check if elements contain product links
          first_element = elements.first
          if first_element && (first_element.css('a[href*="/product/"]').any? || first_element.css('a[href*="/produit/"]').any?)
            return from_html_list(html, selector, %r{/(\d+)/?}i, locale: locale)
          end
        end

        # Fallback: return empty array if no products found
        []
      end

      # page -1 to fetch all pages
      def from_website_page(page_url, page: -1, products_count: nil)
        if page == -1
          if products_count # Avoid one call
            pages_count = (products_count.to_f / 20).ceil
            (1..pages_count).map { |page_i| from_website_page(page_url, page: page_i) }.flatten
          else
            products = []

            page = 1
            loop do
              products_on_page = from_website_page(page_url, page: page)
              products += products_on_page
              page += 1
              break unless products_on_page.any?
            end

            products
          end
        else
          # Try different URL formats for pagination
          urls_to_try = [
            "#{page_url}/#{page}",                    # Original format: /page/1
            "#{page_url}?page=#{page}",               # Query parameter: ?page=1
            "#{page_url}#{page_url.include?('?') ? '&' : '?'}page=#{page}" # Proper query parameter handling
          ]

          html = nil
          urls_to_try.each do |url|
            html = Openfoodfacts.http_get(url).read
            break if html&.length&.positive?
          rescue StandardError
            # Continue to next URL format
            next
          end

          html ||= '' # Fallback to empty string if all URLs fail
          from_website_list(html, locale: Locale.locale_from_link(page_url))
        end
      end

      def tags_from_page(_klass, page_url, &custom_tag_parsing)
        html = Openfoodfacts.http_get(page_url).read
        dom = Nokogiri::HTML.fragment(html)

        dom.css('table#tagstable tbody tr').map do |tag|
          if custom_tag_parsing
            custom_tag_parsing.call(tag)
          else
            link = tag.css('a').first

            name = link.text.strip
            img_alt = link.css('img').attr('alt')
            if (name.nil? || name == '') && img_alt
              img_alt_text = img_alt.to_s.strip
              name = if img_alt_text.include?(':')
                       img_alt_text.split(':').last.strip
                     else
                       img_alt_text[/\s+([^\s]+)$/, 1]
                     end
            end

            _klass.new({
                         'name' => name,
                         'url' => URI.join(page_url, link.attr('href')).to_s,
                         'products_count' => tag.css('td')[1].text.to_i
                       })
          end
        end
      end
    end

    # Fetch product
    #
    def fetch
      if code
        product = self.class.get(code)
        merge!(product) if product
      end

      self
    end
    alias reload fetch

    # Update product
    # Only product_name, brands and quantity fields seems to be updatable throught app / API.
    # User can be nil
    # Tested not updatable fields: countries, ingredients_text, purchase_places, purchase_places_tag, purchase_places_tags
    #
    def update(user: nil, domain: DEFAULT_DOMAIN)
      if code && lc
        subdomain = lc == 'world' ? 'world' : "world-#{lc}"
        path = 'cgi/product_jqm.pl'
        uri = URI("https://#{subdomain}.#{domain}/#{path}")
        params = to_hash
        params.merge!('user_id' => user.user_id, 'password' => user.password) if user
        response = Net::HTTP.post_form(uri, params)

        data = JSON.parse(response.body)
        data['status'] == 1
      else
        false
      end
    end
    alias save update

    # Return Product API URL
    #
    def url(locale: DEFAULT_LOCALE)
      self.class.url(code, locale: locale)
    end

    # Return Product web URL according to locale
    #
    def weburl(locale: nil, domain: DEFAULT_DOMAIN)
      locale ||= lc || DEFAULT_LOCALE

      if code && (prefix = LOCALE_WEBURL_PREFIXES[locale])
        path = "#{prefix}/#{code}"
        "https://#{locale}.#{domain}/#{path}"
      end
    end
  end
end
