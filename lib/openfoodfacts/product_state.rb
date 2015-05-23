require 'hashie'
require 'nokogiri'
require 'open-uri'

module Openfoodfacts
  class ProductState < Hashie::Mash

    class << self

      # Get product states
      #
      def all
        url = "http://world.openfoodfacts.org/states"
        html = open(url).read
        dom = Nokogiri::HTML.fragment(html)
        
        dom.css('table#tagstable tbody tr').map do |product_state|
          link = product_state.css('a').first

          new({
            "name" => link.text.strip,
            "url" => URI.join(url, link.attr('href')).to_s,
            "products_count" => product_state.css('td').last.text.to_i
          })
        end
      end

    end

    # Get products with state
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