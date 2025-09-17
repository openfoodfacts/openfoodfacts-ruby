require 'hashie'

module Openfoodfacts
  class Trace < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'traces',
      'uk' => 'traces',
      'us' => 'traces',
      'world' => 'traces'
    }

    class << self

      # Get traces
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "https://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with trace
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
