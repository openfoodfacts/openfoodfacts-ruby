require 'hashie'

module Openfoodfacts
  class NumberOfIngredients < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'nombres-d-ingredients',
      'uk' => 'numbers-of-ingredients',
      'us' => 'numbers-of-ingredients',
      'world' => 'numbers-of-ingredients'
    }

    class << self

      # Get last edit dates
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "https://#{locale}.#{domain}/facets/#{path}")
        end
      end

    end

    # Get products with last edit date
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
