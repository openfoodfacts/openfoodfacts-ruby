require 'hashie'
require 'nokogiri'
require 'open-uri'
require 'time'

module Openfoodfacts
  class Press < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'presse',
      'uk' => 'press',
      'us' => 'press',
      'world' => 'press'
    }

    LOCALE_DATE_FORMATS = {
      'fr' => '%d/%m/%Y',
      'uk' => '%m/%d/%Y',
      'us' => '%m/%d/%Y',
      'world' => '%m/%d/%Y'
    }

    class << self
      def items(locale: Openfoodfacts::DEFAULT_LOCALE, domain: Openfoodfacts::DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          html = open("http://#{locale}.#{domain}/#{path}").read
          dom = Nokogiri::HTML.fragment(html)

          titles = dom.css('#main_column li')
          titles.each_with_index.map do |item, index|
            data = item.inner_html.split(' - ')

            link = Nokogiri::HTML.fragment(data.first).css('a')
            attributes = {
              "title" => link.text.strip,
              "url" => link.attr('href').value
            }

            last = Nokogiri::HTML.fragment(data.last)
            if date_format = LOCALE_DATE_FORMATS[locale] and date = last.text.strip[/\d+\/\d+\/\d+\z/, 0]
              attributes["date"] = DateTime.strptime(date, date_format)
            end

            if data.length >= 3
              attributes["source"] = Nokogiri::HTML.fragment(data[-2]).text.strip
            end

            new(attributes)
          end
        end
      end
    end

  end
end
