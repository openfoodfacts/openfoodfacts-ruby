module Openfoodfacts
  class Locale < String

    GLOBAL = 'world'

    class << self

      # Get locales
      #
      def all(domain: DEFAULT_DOMAIN)
        path = "cgi/countries.pl"
        url = "https://#{GLOBAL}.#{domain}/#{path}"
        json = Openfoodfacts.http_get(url).read
        hash = JSON.parse(json)

        hash.map { |pair|
          locale_from_pair(pair, domain: domain)
        }.compact
      end

      # Return locale from link
      #
      def locale_from_link(link)
        locale = link[/^https?:\/\/([^.]+)\./i, 1]
        locale unless locale.nil? || locale == 'static'
      end

      # Return locale from pair
      #
      def locale_from_pair(pair, domain: DEFAULT_DOMAIN)
        code = pair.first
        {
          "name" => pair.last.strip,
          "code" => code,
          "url" => "https://#{code}.#{domain}"
        } if code
      end

    end

  end
end
