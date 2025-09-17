require 'hashie'

module Openfoodfacts
  class IngredientThatMayBeFromPalmOil < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'ingredients-pouvant-etre-issus-de-l-huile-de-palme',
      'uk' => 'ingredients-that-may-be-from-palm-oil',
      'us' => 'ingredients-that-may-be-from-palm-oil',
      'world' => 'ingredients-that-may-be-from-palm-oil'
    }

    class << self

      # Get ingredients that may be from palm oil
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "https://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with ingredient that may be from palm oil
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
