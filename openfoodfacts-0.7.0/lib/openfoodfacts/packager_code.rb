require 'hashie'

module Openfoodfacts
  class PackagerCode < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'codes-emballeurs',
      'uk' => 'packager-codes',
      'us' => 'packager-codes',
      'world' => 'packager-codes'
    }

    class << self

      # Get packager codes
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "https://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with packager code
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
