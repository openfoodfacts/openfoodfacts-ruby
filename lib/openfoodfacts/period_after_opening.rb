# frozen_string_literal: true

require 'hashie'

module Openfoodfacts
  class PeriodAfterOpening < Hashie::Mash
    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'durees-d-utilisation-apres-ouverture',
      'uk' => 'periods-after-opening',
      'us' => 'periods-after-opening',
      'world' => 'periods-after-opening'
    }.freeze

    class << self
      # Get labels
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if (path = LOCALE_PATHS[locale])
          Product.tags_from_page(self, "https://#{locale}.#{domain}/#{path}")
        end
      end
    end

    # Get products with label
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end
  end
end
