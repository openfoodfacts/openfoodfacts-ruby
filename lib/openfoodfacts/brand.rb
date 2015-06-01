require 'hashie'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  class Brand < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'en' => 'brands',
      'fr' => 'marques',
      'world' => 'brands'
    }

    class << self

      # Get product brands
      #
      def all(locale: Openfoodfacts::DEFAULT_LOCALE)
        if path = LOCALE_PATHS[locale]
          url = "http://#{locale}.openfoodfacts.org/#{path}"
          html = open(url).read
          dom = Nokogiri::HTML.fragment(html)
          
          dom.css('table#tagstable tbody tr').map do |brand|
            link = brand.css('a').first

            new({
              "name" => link.text.strip,
              "url" => URI.join(url, link.attr('href')).to_s,
              "products_count" => brand.css('td').last.text.to_i
            })
          end
        end
      end

    end

    # Get products with brand
    #
    def products(page: -1)
      if url
        if page == -1
          if products_count
            pages_count = (products_count.to_f / 20).ceil
            (1..pages_count).map { |page| products(page: page) }.flatten
          end
        else
          page_url = "#{url}/#{page}"
          html = open(page_url).read
          
          Product.from_website_list(html)
        end
      end
    end

  end
end