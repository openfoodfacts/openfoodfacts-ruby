require 'hashie'
require 'json'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  class Product < Hashie::Mash
    class << self

      # Get product
      #
      def get(barcode, locale: Openfoodfacts::DEFAULT_LOCALE)
        product_url = url(barcode, locale: locale)
        json = open(product_url).read
        hash = JSON.parse(json)

        new(hash["product"]) if !hash["status"].nil? && hash["status"] == 1
      end

      # Return product API URL
      #
      def url(barcode, locale: Openfoodfacts::DEFAULT_LOCALE)
        "http://#{locale}.openfoodfacts.org/api/v0/produit/#{barcode}.json"
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

    end
  end
end