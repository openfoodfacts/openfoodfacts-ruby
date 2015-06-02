require 'hashie'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  class Brand < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'en' => 'brands',
      'fr' => 'marques',
      'world' => 'brands'
    }

    class << self

      # Get product brands
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.openfoodfacts.org/#{path}")
        end
      end

    end

    # Get products with brand
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end