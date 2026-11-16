# frozen_string_literal: true

require 'hashie'
require 'nokogiri'
require 'time'

module Openfoodfacts
  # Represents press coverage entries on Open Food Facts.
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
        return unless (path = LOCALE_PATHS[locale])

        date_format = LOCALE_DATE_FORMATS[locale]
        html = Openfoodfacts.http_get("https://#{locale}.#{domain}/#{path}").read
        Nokogiri::HTML.fragment(html).css('#press_table tbody tr').map { |item| parse_item(item, date_format) }
      end

      private

      def parse_item(item, date_format)
        type_col, title_col, source_col, date_col = item.css('td')
        new(
          'type' => type_col.text,
          'title' => title_col.text.strip,
          'url' => title_col.css('a')&.attr('href')&.value,
          'source' => source_col.text.strip,
          'date' => parse_date(date_col.text, date_format)
        )
      end

      def parse_date(text, date_format)
        DateTime.strptime(text, date_format)
      rescue StandardError
        nil
      end
    end
  end
end
