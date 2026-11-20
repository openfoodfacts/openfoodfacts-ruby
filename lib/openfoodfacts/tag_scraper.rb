# frozen_string_literal: true

module Openfoodfacts
  # Tag table scraping helpers for Openfoodfacts::Product.
  module TagScraper
    def tags_from_page(klass, page_url, &custom_tag_parsing)
      html = Openfoodfacts.http_get(page_url).read
      Nokogiri::HTML.fragment(html).css('table#tagstable tbody tr').map do |tag|
        custom_tag_parsing ? custom_tag_parsing.call(tag) : parse_default_tag(klass, tag, page_url)
      end
    end

    private

    def parse_default_tag(klass, tag, page_url)
      link = tag.css('a').first
      klass.new(
        'name' => extract_tag_name(link),
        'url' => URI.join(page_url, link.attr('href')).to_s,
        'products_count' => tag.css('td')[1].text.to_i
      )
    end

    def extract_tag_name(link)
      name = link.text.strip
      return name unless name.nil? || name.empty?

      img_alt = link.css('img').attr('alt')
      return name unless img_alt

      img_alt_text = img_alt.to_s.strip
      img_alt_text.include?(':') ? img_alt_text.split(':').last.strip : img_alt_text[/\s+([^\s]+)$/, 1]
    end
  end
end
