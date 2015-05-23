require 'hashie'
require 'net/http'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  class Product < Hashie::Mash

    class << self

      # Get product
      #
      def get(code, locale: Openfoodfacts::DEFAULT_LOCALE)
        if code
          product_url = url(code, locale: locale)
          json = open(product_url).read
          hash = JSON.parse(json)

          new(hash["product"]) if !hash["status"].nil? && hash["status"] == 1
        end
      end
      alias_method :find, :get

      # Return product API URL
      #
      def url(code, locale: Openfoodfacts::DEFAULT_LOCALE)
        "http://#{locale}.openfoodfacts.org/api/v0/produit/#{code}.json"
      end

      # Search products 
      #
      def search(terms, locale: Openfoodfacts::DEFAULT_LOCALE, page: 1, page_size: 20, sort_by: 'unique_scans_n')
        url = "http://#{locale}.openfoodfacts.org/cgi/search.pl?search_terms=#{terms}&jqm=1&page=#{page}&page_size=#{page_size}&sort_by=#{sort_by}"
        json = open(url).read
        hash = JSON.parse(json)
        html = hash["jqm"]

        from_jquery_mobile_list(html)
      end
      alias_method :where, :search

      def from_html_list(html, list_css_selector, code_from_link_regex)
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

          new(attributes)
        end

      end

      def from_jquery_mobile_list(jqm_html)
        from_html_list(jqm_html, 'ul li:not(#loadmore)', /code=(\d+)\Z/i)
      end

      def from_website_list(html)
        from_html_list(html, 'ul.products li', /\/(\d+)[\/|\Z]/i)
      end

    end

    # Fetch product
    #
    def fetch
      if (self.code)
        product = self.class.get(self.code)
        self.merge!(product)
      end

      self
    end
    alias_method :reload, :fetch

    # Update product
    # Only product_name, brands and quantity fields seems to be updatable throught app / API.
    # User can be nil
    # Tested not updatable fields: countries, ingredients_text, purchase_places, purchase_places_tag, purchase_places_tags
    #
    def update(user: nil)
      if self.code && self.lc
        uri = URI("http://#{self.lc}.openfoodfacts.org/cgi/product_jqm.pl")
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
    def url(locale: Openfoodfacts::DEFAULT_LOCALE)
      self.class.url(self.code, locale: locale)
    end

  end
end