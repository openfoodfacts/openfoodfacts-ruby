# frozen_string_literal: true

require 'hashie'
require 'nokogiri'
require 'time'

module Openfoodfacts
  class Press < Hashie::Mash
    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'revue-de-presse-fr'
    }.freeze

    LOCALE_DATE_FORMATS = {
      'fr' => '%d/%m/%Y'
    }.freeze

    class << self
      def items(locale: 'fr', domain: DEFAULT_DOMAIN)
        if (path = LOCALE_PATHS[locale])
          date_format = LOCALE_DATE_FORMATS[locale]

          html = Openfoodfacts.http_get("https://#{locale}.#{domain}/#{path}").read
          dom = Nokogiri::HTML.fragment(html)

          titles = dom.css('#press_table tbody tr')
          titles.each_with_index.map do |item, _index|
            colums = item.css('td')

            link = colums[1].css('a')
            attributes = {
              'type' => colums[0].text,
              'title' => colums[1].text.strip,
              'url' => link&.attr('href')&.value,
              'source' => colums[2].text.strip,
              'date' => begin
                DateTime.strptime(colums[3].text, date_format)
              rescue StandardError
                nil
              end
            }

            new(attributes)
          end
        end
      end
    end
  end
end
