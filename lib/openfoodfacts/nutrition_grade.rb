# frozen_string_literal: true

require 'hashie'

module Openfoodfacts
  class NutritionGrade < Hashie::Mash
    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'notes-nutritionnelles',
      'uk' => 'nutrition-grades',
      'us' => 'nutrition-grades',
      'world' => 'nutrition-grades'
    }.freeze

    class << self
      # Get nutrition grades
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if (path = LOCALE_PATHS[locale])
          Product.tags_from_page(self, "https://#{locale}.#{domain}/facets/#{path}")
        end
      end
    end

    # Get products with nutrition grade
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end
  end
end
