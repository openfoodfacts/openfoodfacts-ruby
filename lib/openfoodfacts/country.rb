require 'hashie'

module Openfoodfacts
  class Country < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'pays',
      'uk' => 'countries',
      'us' => 'countries',
      'world' => 'countries'
    }

    class << self

      # Get countries
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE, domain: 'openfoodfacts.org')
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with country
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
