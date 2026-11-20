# frozen_string_literal: true

require_relative 'minitest_helper'

class TestOpenfoodfacts < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Openfoodfacts::VERSION
  end

  def test_it_fetches_locales
    VCR.use_cassette('index') do
      locales = ::Openfoodfacts::Locale.all
      assert_includes locales.map { |locale| locale['code'] }, 'gd'
    end
  end

  def test_it_login_user
    VCR.use_cassette('login_user', record: :once, match_requests_on: %i[host path]) do
      user = ::Openfoodfacts::User.login('wrong', 'absolutely')
      assert_nil user
    end
  end

  def test_it_returns_product_url
    product = ::Openfoodfacts::Product.new(code: '3029330003533')
    assert_equal ::Openfoodfacts::Product.url(product.code, locale: 'ca'), product.url(locale: 'ca')
  end

  def test_it_returns_product_weburl
    product = ::Openfoodfacts::Product.new(code: '3029330003533')
    assert_equal "https://world.openfoodfacts.org/product/#{product.code}", product.weburl(locale: 'world')
  end

  def test_it_fetches_product
    product_code = '3029330003533'
    VCR.use_cassette("fetch_product_#{product_code}", record: :once, match_requests_on: %i[host path]) do
      product = ::Openfoodfacts::Product.new(code: product_code)
      product.fetch
      refute_empty product.brands_tags
    end
  end

  def test_it_get_product
    product_code = '3029330003533'
    VCR.use_cassette("product_#{product_code}", record: :once, match_requests_on: %i[host path]) do
      assert_equal ::Openfoodfacts::Product.get(product_code).code, product_code
    end
  end

  def test_that_it_searches_with_page_size
    term = 'coca'
    VCR.use_cassette("search_#{term}") do
      products = ::Openfoodfacts::Product.search(term, page_size: 42)
      assert_match(/#{term}/i, products.last['product_name'])
      assert_match(/#{term}/i, ::Openfoodfacts::Product.search(term).last['product_name'])
      assert_equal 42, products.size
    end
  end

  def test_that_it_searches_with_pagination
    term = 'coca'
    first_product = VCR.use_cassette("search_#{term}") { ::Openfoodfacts::Product.search(term, page_size: 42).first }
    VCR.use_cassette("search_#{term}_1_000_000") do
      refute_equal ::Openfoodfacts::Product.search(term, page: 2).first.code, first_product.code
    end
  end

  def test_it_fetches_faq
    VCR.use_cassette('faq') do
      refute_empty ::Openfoodfacts::Faq.items(locale: 'fr')
    end
  end

  def test_it_fetches_missions
    VCR.use_cassette('missions') do
      skip('Website have a bug with Missions page on https://fr.openfoodfacts.org/missions')
      refute_empty ::Openfoodfacts::Mission.all(locale: 'fr')
    end
  end

  def test_it_fetches_mission
    VCR.use_cassette('mission', record: :once, match_requests_on: %i[host path]) do
      skip('Website have a bug with Mission page on https://fr.openfoodfacts.org/mission/informateur-100-produits')
      mission = ::Openfoodfacts::Mission.new(url: 'https://fr.openfoodfacts.org/mission/informateur-100-produits')
      mission.fetch
      refute_empty mission.users
    end
  end

  def test_it_fetches_press
    VCR.use_cassette('press') do
      refute_empty ::Openfoodfacts::Press.items(locale: 'fr')
    end
  end

  def test_http_get_with_user_agent
    ENV['OPENFOODFACTS_USER_AGENT'] = 'test-agent'
    uri_mock = Minitest::Mock.new
    uri_mock.expect :open, nil, [{ 'User-Agent' => 'test-agent' }]
    URI.stub(:parse, uri_mock) { ::Openfoodfacts.http_get('https://example.com') }
    assert_mock uri_mock
  end

  def test_http_get_without_user_agent
    ENV.delete('OPENFOODFACTS_USER_AGENT')
    uri_mock = Minitest::Mock.new
    uri_mock.expect :open, nil, [{}]
    URI.stub(:parse, uri_mock) { ::Openfoodfacts.http_get('https://example.com') }
    assert_mock uri_mock
  end
end
