module Openfoodfacts
  class Locale < String

    GLOBAL = 'world'

    class << self

      # Get locales
      #
      def all(domain: DEFAULT_DOMAIN)
        url = "https://#{domain}/"
        body = open(url).read
        dom = Nokogiri.parse(body)

        dom.css('#select_country option').map { |option|
          locale_from_option(option, domain: domain)
        }.compact
      end

      # Return locale from link
      #
      def locale_from_link(link)
        locale = link[/^https?:\/\/([^.]+)\./i, 1]
        locale unless locale.nil? || locale == 'static'
      end

      # Return locale from option
      #
      def locale_from_option(option, domain: DEFAULT_DOMAIN)
        value = option.attr('value')
        {
          "name" => option.text.strip,
          "code" => value,
          "url" => "https://#{value}.#{domain}"
        } if value
      end

    end

  end
end
