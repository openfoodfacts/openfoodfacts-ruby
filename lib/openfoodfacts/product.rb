# frozen_string_literal: true

require 'cgi'
require 'hashie'
require 'net/http'
require 'nokogiri'
require_relative 'product_scraper'
require_relative 'tag_scraper'

module Openfoodfacts
  # Represents a food product on Open Food Facts.
  class Product < Hashie::Mash
    extend ProductScraper
    extend TagScraper

    # disable_warnings
    # TODO: Add more locales
    LOCALE_WEBURL_PREFIXES = {
      'fr' => 'produit',
      'uk' => 'product',
      'us' => 'product',
      'world' => 'product'
    }.freeze

    class << self
      # Get product
      #
      def get(code, locale: DEFAULT_LOCALE)
        return unless code

        product_url = url(code, locale: locale)
        json = Openfoodfacts.http_get(product_url).read
        hash = JSON.parse(json)

        new(hash['product']) if !hash['status'].nil? && hash['status'] == 1
      end
      alias find get

      # Return product API URL
      #
      def url(code, locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        return unless code

        prefix = LOCALE_WEBURL_PREFIXES[locale]
        path = "api/v2/#{prefix}/#{code}.json"
        "https://#{locale}.#{domain}/#{path}"
      end

      # Search products
      #
      def search(terms, **options)
        opts = search_defaults.merge(options)
        query = "search_terms=#{CGI.escape(terms)}&json=1&page=#{opts[:page]}" \
                "&page_size=#{opts[:page_size]}&sort_by=#{opts[:sort_by]}"
        url = "https://#{opts[:locale]}.#{opts[:domain]}/cgi/search.pl?#{query}"
        hash = JSON.parse(Openfoodfacts.http_get(url).read)
        hash['products'].map { |data| new(data) }
      end
      alias where search

      private

      def search_defaults
        { locale: DEFAULT_LOCALE, page: 1, page_size: 20, sort_by: 'unique_scans_n', domain: DEFAULT_DOMAIN }
      end
    end

    # Fetch product
    #
    def fetch
      if code
        product = self.class.get(code)
        merge!(product) if product
      end

      self
    end
    alias reload fetch

    # Update product
    # Only product_name, brands and quantity fields seems to be updatable throught app / API.
    # User can be nil
    # Tested not updatable fields: countries, ingredients_text, purchase_places,
    # purchase_places_tag, purchase_places_tags
    #
    def update(user: nil, domain: DEFAULT_DOMAIN)
      return false unless code && lc

      subdomain = lc == 'world' ? 'world' : "world-#{lc}"
      uri = URI("https://#{subdomain}.#{domain}/cgi/product_jqm.pl")
      response = Net::HTTP.post_form(uri, update_params(user))
      JSON.parse(response.body)['status'] == 1
    end
    alias save update

    # Return Product API URL
    #
    def url(locale: DEFAULT_LOCALE)
      self.class.url(code, locale: locale)
    end

    # Return Product web URL according to locale
    #
    def weburl(locale: nil, domain: DEFAULT_DOMAIN)
      locale ||= lc || DEFAULT_LOCALE

      if code && (prefix = LOCALE_WEBURL_PREFIXES[locale])
        path = "#{prefix}/#{code}"
        "https://#{locale}.#{domain}/#{path}"
      end
    end

    private

    def update_params(user)
      params = to_hash
      params.merge!('user_id' => user.user_id, 'password' => user.password) if user
      params
    end
  end
end
