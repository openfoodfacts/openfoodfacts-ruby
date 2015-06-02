require 'hashie'

module Openfoodfacts
  class ManufacturingPlace < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'lieux-de-fabrication',
      'uk' => 'manufacturing-places',
      'us' => 'manufacturing-places',
      'world' => 'manufacturing-places'
    }

    class << self

      # Get manufacturing places
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.openfoodfacts.org/#{path}")
        end
      end

    end

    # Get products from manufacturing place
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end