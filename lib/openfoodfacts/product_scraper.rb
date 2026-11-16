# frozen_string_literal: true

module Openfoodfacts
  # HTML scraping and tag parsing helpers for Openfoodfacts::Product.
  module ProductScraper
    WEBSITE_LIST_SELECTORS = [
      'ul.products li',           # Original selector
      '.search_results article',  # Modern article-based structure
      '.search-results .result',  # Alternative modern structure
      'article',                  # Simple article tags
      '.product-item',            # Product item classes
      '.product',                 # Simple product classes
      'li[data-product-code]'     # Data attribute based
    ].freeze

    def from_html_list(html, list_css_selector, code_from_link_regex, locale: 'world')
      dom = Nokogiri::HTML.fragment(html)
      dom.css(list_css_selector).filter_map do |product|
        parse_html_product(product, code_from_link_regex, locale)
      end
    end

    def from_website_list(html, locale: 'world')
      dom = Nokogiri::HTML.fragment(html)
      selector = WEBSITE_LIST_SELECTORS.find { |sel| product_elements?(dom, sel) }
      return [] unless selector

      from_html_list(html, selector, %r{/(\d+)/?}i, locale: locale)
    end

    # page -1 to fetch all pages
    def from_website_page(page_url, page: -1, products_count: nil)
      return fetch_all_website_pages(page_url, products_count) if page == -1

      html = fetch_page_html(page_url, page)
      from_website_list(html, locale: Locale.locale_from_link(page_url))
    end

    private

    def parse_html_product(product, code_from_link_regex, locale)
      link = product_link(product)
      return unless link

      code = extract_product_code(link.attr('href'), code_from_link_regex)
      return unless code

      attributes = { 'product_name' => link.inner_text.strip, '_id' => code, 'code' => code }
      extract_product_image(product, attributes)
      attributes['lc'] ||= locale
      new(attributes)
    end

    def product_link(product)
      product.css('a[href*="/product/"], a[href*="/produit/"]').first || product.css('a').first
    end

    def extract_product_code(href, code_from_link_regex)
      regexes = [
        code_from_link_regex,
        %r{/product/(\d+)}i,
        %r{/produit/(\d+)}i,
        %r{/(\d{8,})},
        %r{product[/=](\d+)}i,
        %r{code[/=](\d+)}i
      ]
      regexes.lazy.filter_map { |regex| href[regex, 1] }.find { |match| match.length >= 8 }
    end

    def extract_product_image(product, attributes)
      image = product.css('img').first
      return unless image && (image_url = image.attr('src'))

      attributes['image_small_url'] = image_url
      attributes['lc'] = Locale.locale_from_link(image_url)
    end

    def product_elements?(dom, selector)
      first_element = dom.css(selector).first
      return false unless first_element

      first_element.css('a[href*="/product/"], a[href*="/produit/"]').any?
    end

    def fetch_all_website_pages(page_url, products_count)
      if products_count
        pages_count = (products_count.to_f / 20).ceil
        return (1..pages_count).flat_map { |page_i| from_website_page(page_url, page: page_i) }
      end

      collect_paginated_products(page_url)
    end

    def collect_paginated_products(page_url)
      products = []
      page = 1
      loop do
        products_on_page = from_website_page(page_url, page: page)
        break if products_on_page.empty?

        products += products_on_page
        page += 1
      end
      products
    end

    def fetch_page_html(page_url, page)
      separator = page_url.include?('?') ? '&' : '?'
      urls_to_try = ["#{page_url}/#{page}", "#{page_url}?page=#{page}", "#{page_url}#{separator}page=#{page}"]
      urls_to_try.each do |url|
        html = Openfoodfacts.http_get(url).read
        return html if html&.length&.positive?
      rescue StandardError
        next
      end
      ''
    end
  end
end
