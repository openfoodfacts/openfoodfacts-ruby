module Openfoodfacts
  class Locale < String

    GLOBAL = 'world'

    class << self

      # Get locales
      #
      def all(domain: 'openfoodfacts.org')
        url = "http://#{domain}/"
        body = open(url).read
        dom = Nokogiri.parse(body)

        dom.css('ul li a').map { |locale_link|
          locale_from_link(locale_link.attr('href'))
        }.uniq.sort
      end

      # Return locale from link
      #
      def locale_from_link(link)
        locale = link[/^https?:\/\/([^.]+)\./i, 1]
        locale unless locale.nil? || locale == 'static'
      end

    end

  end
end
