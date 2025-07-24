require 'hashie'
require 'nokogiri'

module Openfoodfacts
  class Faq < Hashie::Mash

    # TODO: Add more locales
    LOCALE_PATHS = {
      'fr' => 'questions-frequentes',
      'uk' => 'faq',
      'us' => 'faq',
      'world' => 'faq'
    }

    class << self
      def items(locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        if path = LOCALE_PATHS[locale]
          html = Openfoodfacts.http_get("https://#{locale}.#{domain}/#{path}").read
          dom = Nokogiri::HTML.fragment(html)

          titles = dom.css('#main_column h2')
          titles.each_with_index.map do |item, index|
            paragraphs = []

            element = item.next_sibling
            while !element.nil? && element.node_name != 'h2'
              if element.node_name == 'p'
                paragraphs.push(element)
              end

              element = element.next_sibling
            end

            if index == titles.length - 1
              paragraphs = paragraphs[0..-3]
            end

            new({
              "question" => item.text.strip,
              "answer" => paragraphs.map { |paragraph| paragraph.text.strip.gsub(/\r?\n/, ' ') }.join("\n\n"),
              "answer_html" => paragraphs.map(&:to_html).join
            })
          end
        end
      end
    end

  end
end
