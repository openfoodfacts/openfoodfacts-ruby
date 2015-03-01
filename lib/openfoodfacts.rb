require_relative 'openfoodfacts/product'
require_relative 'openfoodfacts/version'

require 'json'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  DEFAULT_LOCALE = 'en'

  class << self

    # Get locales
    #
    def locales
      url = "http://openfoodfacts.org/"
      body = open(url).read
      dom = Nokogiri.parse(body)

      dom.css('ul li a').map { |locale_link|
        locale_link.attr('href')[/^https?:\/\/([^.]+)\./i,1]
      }.uniq.sort
    end

    # Get product
    #
    def product(barcode, locale: DEFAULT_LOCALE)
      url = product_url(barcode, locale: locale)
      json = open(url).read
      hash = JSON.parse(json)

      Product.new(hash["product"]) if !hash["status"].nil? && hash["status"] == 1
    end

    # Get product API URL
    #
    def product_url(barcode, locale: DEFAULT_LOCALE)
      "http://#{locale}.openfoodfacts.org/api/v0/produit/#{barcode}.json"
    end

  end
end