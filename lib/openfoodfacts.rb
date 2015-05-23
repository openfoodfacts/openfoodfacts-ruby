require_relative 'openfoodfacts/locale'
require_relative 'openfoodfacts/product'
require_relative 'openfoodfacts/product_state'
require_relative 'openfoodfacts/user'
require_relative 'openfoodfacts/version'

require 'json'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts

  DEFAULT_LOCALE = Locale::GLOBAL

  class << self

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