# frozen_string_literal: true

require_relative 'openfoodfacts/additive'
require_relative 'openfoodfacts/brand'
require_relative 'openfoodfacts/category'
require_relative 'openfoodfacts/city'
require_relative 'openfoodfacts/contributor'
require_relative 'openfoodfacts/country'
require_relative 'openfoodfacts/entry_date'
require_relative 'openfoodfacts/faq'
require_relative 'openfoodfacts/ingredient_that_may_be_from_palm_oil'
require_relative 'openfoodfacts/label'
require_relative 'openfoodfacts/language'
require_relative 'openfoodfacts/last_edit_date'
require_relative 'openfoodfacts/locale'
require_relative 'openfoodfacts/manufacturing_place'
require_relative 'openfoodfacts/mission'
require_relative 'openfoodfacts/number_of_ingredients'
require_relative 'openfoodfacts/nutrition_grade'
require_relative 'openfoodfacts/origin'
require_relative 'openfoodfacts/packager_code'
require_relative 'openfoodfacts/packaging'
require_relative 'openfoodfacts/press'
require_relative 'openfoodfacts/product'
require_relative 'openfoodfacts/product_state'
require_relative 'openfoodfacts/purchase_place'
require_relative 'openfoodfacts/store'
require_relative 'openfoodfacts/trace'
require_relative 'openfoodfacts/user'
require_relative 'openfoodfacts/version'

require 'json'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  DEFAULT_LOCALE = Locale::GLOBAL
  DEFAULT_DOMAIN = 'openfoodfacts.org'

  class << self
    # Centralized HTTP client method with User-Agent header
    #
    def http_get(url)
      user_agent = ENV.fetch('OPENFOODFACTS_USER_AGENT', nil)
      headers = user_agent ? { 'User-Agent' => user_agent } : {}
      URI.parse(url).open(headers)
    end

    # Return locale from link
    #
    def locale_from_link(link)
      Locale.locale_from_link(link)
    end

    # Get locales
    #
    def locales
      Locale.all
    end

    # Get product
    #
    def product(barcode, locale: DEFAULT_LOCALE)
      Product.get(barcode, locale: locale)
    end

    # Return product API URL
    #
    def product_url(barcode, locale: DEFAULT_LOCALE)
      Product.url(barcode, locale: locale)
    end
  end
end
