require 'hashie'

module Openfoodfacts
  class Category < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'categories',
      'uk' => 'categories',
      'us' => 'categories',
      'world' => 'categories'
    }

    class << self

      # Get categories
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.openfoodfacts.org/#{path}")
        end
      end

    end

    # Get products with category
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end