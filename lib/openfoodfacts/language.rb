require 'hashie'

module Openfoodfacts
  class Language < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'langues',
      'uk' => 'languages',
      'us' => 'languages',
      'world' => 'languages'
    }

    class << self

      # Get languages
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "https://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with language
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
