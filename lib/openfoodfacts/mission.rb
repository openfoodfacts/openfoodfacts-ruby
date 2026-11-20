# frozen_string_literal: true

require 'hashie'

module Openfoodfacts
  # Represents a contribution mission on Open Food Facts.
  class Mission < Hashie::Mash
    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'missions',
      'uk' => 'missions',
      'us' => 'missions',
      'world' => 'missions'
    }.freeze

    class << self
      def all(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        return unless (path = LOCALE_PATHS[locale])

        url = "https://#{locale}.#{domain}/#{path}"
        dom = Nokogiri::HTML.fragment(Openfoodfacts.http_get(url).read)
        dom.css('#missions li').map { |mission_dom| parse_item(mission_dom, url) }
      end

      private

      def parse_item(mission_dom, page_url)
        links = mission_dom.css('a')
        new(
          'title' => links.first.text.strip,
          'url' => URI.join(page_url, links.first.attr('href')).to_s,
          'description' => extract_description(mission_dom),
          'users_count' => links.last.text[/(\d+)/, 1].to_i
        )
      end

      def extract_description(mission_dom)
        mission_dom.css('div').first.children[2].text.gsub('→', '').strip
      end
    end

    # Fetch mission
    #
    def fetch
      if url
        dom = Nokogiri::HTML.fragment(Openfoodfacts.http_get(url).read)
        merge!(extract_attributes(dom))
      end

      self
    end
    alias reload fetch

    private

    def extract_attributes(dom)
      description = dom.css('#description').first
      users = parse_users(dom)
      {
        'title' => dom.css('h1').first.text.strip,
        'description' => description.text.strip,
        'description_long' => description.next.text.strip,
        'users' => users,
        'users_count' => users.count
      }
    end

    def parse_users(dom)
      # Remove "All missions" link
      dom.css('#main_column a')[0..-2].map do |user_link|
        User.new(
          'user_id' => user_link.text.strip,
          'url' => URI.join(url, user_link.attr('href')).to_s
        )
      end
    end
  end
end
