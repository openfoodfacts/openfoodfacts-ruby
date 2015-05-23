require 'hashie'
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

        results_jqm = hash["jqm"]
        results_dom = Nokogiri::HTML.fragment(results_jqm)
        
        results_dom.css('li:not(#loadmore)').map do |product|
          attributes = {}

          if link = product.css('a').first
            attributes["product_name"] = link.inner_text.strip

            if code = link.attr('href').split('=').last
              attributes["_id"] = code
              attributes["code"] = code
            end
          end

          if image = product.css('img').first and image_url = image.attr('src')
            attributes["image_small_url"] = image_url
            attributes["lc"] = Openfoodfacts.locale_from_link(image_url)
          end

          new(attributes)
        end
      end
      alias_method :where, :search

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

    # Return Product API URL
    #
    def url(locale: Openfoodfacts::DEFAULT_LOCALE)
      self.class.url(self.code, locale: locale)
    end

  end
end