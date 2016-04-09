require 'hashie'

module Openfoodfacts
  class Contributor < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'contributeurs',
      'uk' => 'contributors',
      'us' => 'contributors',
      'world' => 'contributors'
    }

    class << self

      # Get contributors
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE, domain: Openfoodfacts::DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "http://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products for contributor
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
