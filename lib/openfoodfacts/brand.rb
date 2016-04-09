require 'hashie'

module Openfoodfacts
  class Brand < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'marques',
      'uk' => 'brands',
      'us' => 'brands',
      'world' => 'brands'
    }

    class << self

      # Get product brands
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.#{domain}/#{path}")
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
