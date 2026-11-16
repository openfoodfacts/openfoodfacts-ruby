# frozen_string_literal: true

require 'hashie'
require 'nokogiri'

module Openfoodfacts
  # Represents FAQ entries on Open Food Facts.
  class Faq < Hashie::Mash
    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'questions-frequentes',
      'uk' => 'faq',
      'us' => 'faq',
      'world' => 'faq'
    }.freeze

    class << self
      def items(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        return unless (path = LOCALE_PATHS[locale])

        html = Openfoodfacts.http_get("https://#{locale}.#{domain}/#{path}").read
        titles = Nokogiri::HTML.fragment(html).css('#main_column h2')
        last_index = titles.length - 1
        titles.each_with_index.map { |item, index| parse_item(item, index == last_index) }
      end

      private

      def parse_item(item, last_item)
        paragraphs = collect_paragraphs(item, last_item)
        new(
          'question' => item.text.strip,
          'answer' => paragraphs.map { |paragraph| paragraph.text.strip.gsub(/\r?\n/, ' ') }.join("\n\n"),
          'answer_html' => paragraphs.map(&:to_html).join
        )
      end

      def collect_paragraphs(item, last_item)
        paragraphs = []
        element = item.next_sibling
        while element && element.node_name != 'h2'
          paragraphs.push(element) if element.node_name == 'p'
          element = element.next_sibling
        end
        last_item ? paragraphs[0..-3] : paragraphs
      end
    end
  end
end
