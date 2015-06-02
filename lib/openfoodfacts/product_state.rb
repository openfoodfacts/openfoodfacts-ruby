require 'hashie'

module Openfoodfacts
  class ProductState < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'etats',
      'uk' => 'states',
      'us' => 'states',
      'world' => 'states'
    }

    class << self

      # Get product states
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.openfoodfacts.org/#{path}")
        end
      end

    end

    # Get products with state
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end