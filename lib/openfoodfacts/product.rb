require 'cgi'
require 'hashie'
require 'net/http'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  class Product < Hashie::Mash
    # disable_warnings
    # TODO: Add more locales
    LOCALE_WEBURL_PREFIXES = {
      'fr' => 'produit',
      'uk' => 'product',
      'us' => 'product',
      'world' => 'product'
    }

    class << self

      # Get product
      #
      def get(code, locale: DEFAULT_LOCALE)
        if code
          product_url = url(code, locale: locale)
          json = URI.open(product_url).read
          hash = JSON.parse(json)

          new(hash["product"]) if !hash["status"].nil? && hash["status"] == 1
        end
      end
      alias_method :find, :get

      # Return product API URL
      #
      def url(code, locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if code
          prefix = LOCALE_WEBURL_PREFIXES[locale]
          path = "api/v2/#{prefix}/#{code}.json"
          "https://#{locale}.#{domain}/#{path}"
        end
      end

      # Search products
      #
      def search(terms, locale: DEFAULT_LOCALE, page: 1, page_size: 20, sort_by: 'unique_scans_n', domain: DEFAULT_DOMAIN)
        terms = CGI.escape(terms)
        path = "cgi/search.pl?search_terms=#{terms}&json=1&page=#{page}&page_size=#{page_size}&sort_by=#{sort_by}"
        url = "https://#{locale}.#{domain}/#{path}"
        json = URI.open(url).read
        hash = JSON.parse(json)
        products = []
        hash["products"].each do |data|
          products << new(data)
        end
        products
      end
      alias_method :where, :search

      def from_html_list(html, list_css_selector, code_from_link_regex, locale: 'world')
        dom = Nokogiri::HTML.fragment(html)
        dom.css(list_css_selector).map do |product|
          attributes = {}

          if link = product.css('a').first
            attributes["product_name"] = link.inner_text.strip

            if code = link.attr('href')[code_from_link_regex, 1]
              attributes["_id"] = code
              attributes["code"] = code
            end
          end

          if image = product.css('img').first and image_url = image.attr('src')
            attributes["image_small_url"] = image_url
            attributes["lc"] = Locale.locale_from_link(image_url)
          end
          attributes["lc"] ||= locale

          new(attributes)
        end

      end

      def from_website_list(html, locale: 'world')
        from_html_list(html, 'ul.products li', /\/(\d+)\/?/i, locale: 'world')
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
            begin
              products_on_page = from_website_page(page_url, page: page)
              products += products_on_page
              page += 1
            end while products_on_page.any?

            products
          end
        else
          html = URI.open("#{page_url}/#{page}").read
          from_website_list(html, locale: Locale.locale_from_link(page_url))
        end
      end

      def tags_from_page(_klass, page_url, &custom_tag_parsing)
        html = URI.open(page_url).read
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
              "name" => name,
              "url" => URI.join(page_url, link.attr('href')).to_s,
              "products_count" => tag.css('td')[1].text.to_i
            })
          end
        end
      end

    end

    # Fetch product
    #
    def fetch
      if self.code
        product = self.class.get(self.code)
        self.merge!(product) if product
      end

      self
    end
    alias_method :reload, :fetch

    # Update product
    # Only product_name, brands and quantity fields seems to be updatable throught app / API.
    # User can be nil
    # Tested not updatable fields: countries, ingredients_text, purchase_places, purchase_places_tag, purchase_places_tags
    #
    def update(user: nil, domain: DEFAULT_DOMAIN)
      if self.code && self.lc
        subdomain = self.lc == 'world' ? 'world' : "world-#{self.lc}"
        path = 'cgi/product_jqm.pl'
        uri = URI("https://#{subdomain}.#{domain}/#{path}")
        params = self.to_hash
        params.merge!("user_id" => user.user_id, "password" => user.password) if user
        response = Net::HTTP.post_form(uri, params)

        data = JSON.parse(response.body)
        data["status"] == 1
      else
        false
      end
    end
    alias_method :save, :update

    # Return Product API URL
    #
    def url(locale: DEFAULT_LOCALE)
      self.class.url(self.code, locale: locale)
    end

    # Return Product web URL according to locale
    #
    def weburl(locale: nil, domain: DEFAULT_DOMAIN)
      locale ||= self.lc || DEFAULT_LOCALE

      if self.code && prefix = LOCALE_WEBURL_PREFIXES[locale]
        path = "#{prefix}/#{self.code}"
        "https://#{locale}.#{domain}/#{path}"
      end
    end

  end
end
