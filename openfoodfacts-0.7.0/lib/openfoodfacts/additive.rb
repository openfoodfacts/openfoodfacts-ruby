require 'hashie'

module Openfoodfacts
  class Additive < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'additifs',
      'uk' => 'additives',
      'us' => 'additives',
      'world' => 'additives'
    }

    class << self

      # Get additives
      #
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          page_url = "https://#{locale}.#{domain}/facets/#{path}"

          Product.tags_from_page(self, page_url) do |tag|
            columns = tag.css('td')

            link = tag.css('a').first
            attributes = {
              "name" => link.text.strip,
              "url" => URI.join(page_url, link.attr('href')).to_s,
              "products_count" => columns[1].text.to_i
            }

            riskiness = columns.last.attr('class')
            if riskiness
              attributes["riskiness"] = riskiness[/level_(\d+)/, 1].to_i
            end

            new(attributes)
          end
        end
      end

    end

    # Get products with additive
    #
    def products(page: -1)
      Product.from_website_page(url, page: page, products_count: products_count) if url
    end

  end
end
