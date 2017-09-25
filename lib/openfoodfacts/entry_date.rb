require 'hashie'

module Openfoodfacts
  class EntryDate < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'dates-d-ajout',
      'uk' => 'entry-dates',
      'us' => 'entry-dates',
      'world' => 'entry-dates'
    }

    class << self

      # Get entry dates
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          Product.tags_from_page(self, "https://#{locale}.#{domain}/#{path}")
        end
      end

    end

    # Get products with entry date
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
