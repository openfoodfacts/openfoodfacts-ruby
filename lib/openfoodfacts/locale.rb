module Openfoodfacts
  class Locale < String

    GLOBAL = 'world'

    class << self

      # Get locales
      #
      def all
        url = "http://openfoodfacts.org/"
        body = open(url).read
        dom = Nokogiri.parse(body)

        dom.css('ul li a').map { |locale_link|
          locale_from_link(locale_link.attr('href'))
        }.uniq.sort
      end

      # Return locale from link
      #
      def locale_from_link(link)
        link[/^https?:\/\/([^.]+)\./i, 1]
      end

    end

  end
end