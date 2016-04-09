require 'hashie'

module Openfoodfacts
  class Origin < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'origines',
      'uk' => 'origins',
      'us' => 'origins',
      'world' => 'origins'
    }

    class << self

      # Get origins
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE, domain: Openfoodfacts::DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with origin
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
