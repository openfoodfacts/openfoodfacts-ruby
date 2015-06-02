require 'hashie'

module Openfoodfacts
  class City < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'communes',
      'uk' => 'cities',
      'us' => 'cities',
      'world' => 'cities'
    }

    class << self

      # Get cities
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.openfoodfacts.org/#{path}")
        end
      end

    end

    # Get products with city
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end