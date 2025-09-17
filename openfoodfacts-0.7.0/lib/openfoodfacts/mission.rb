require 'hashie'

module Openfoodfacts
  class Mission < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'missions',
      'uk' => 'missions',
      'us' => 'missions',
      'world' => 'missions'
    }

    class << self
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          url = "https://#{locale}.#{domain}/#{path}"
          html = Openfoodfacts.http_get(url).read
          dom = Nokogiri::HTML.fragment(html)

          dom.css('#missions li').map do |mission_dom|
            links = mission_dom.css('a')

            attributes = {
              "title" => links.first.text.strip,
              "url" => URI.join(url, links.first.attr('href')).to_s,
              "description" => mission_dom.css('div').first.children[2].text.gsub('→', '').strip,
              "users_count" => links.last.text[/(\d+)/, 1].to_i
            }

            new(attributes)
          end
        end
      end
    end

    # Fetch mission
    #
    def fetch
      if (self.url)
        html = Openfoodfacts.http_get(self.url).read
        dom = Nokogiri::HTML.fragment(html)

        description = dom.css('#description').first

        # Remove "All missions" link
        users = dom.css('#main_column a')[0..-2].map do |user_link|
          User.new(
            "user_id" => user_link.text.strip,
            "url" => URI.join(self.url, user_link.attr('href')).to_s,
          )
        end

        mission = {
          "title" => dom.css('h1').first.text.strip,
          "description" => description.text.strip,
          "description_long" => description.next.text.strip,

          "users" => users,
          "users_count" => users.count
        }

        self.merge!(mission)
      end

      self
    end
    alias_method :reload, :fetch

  end
end
