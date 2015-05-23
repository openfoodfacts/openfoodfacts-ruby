require_relative 'minitest_helper'

class TestOpenfoodfacts < Minitest::Test

  # Gem

  def test_that_it_has_a_version_number
    refute_nil ::Openfoodfacts::VERSION
  end

  # Locale

  def test_it_fetches_locales
    VCR.use_cassette("index") do
      locales = ::Openfoodfacts::Locale.all
      assert_includes locales, "world"
      assert_includes locales, "fr"
      assert_includes locales, "be-fr"
    end
  end

  # User

  def test_it_login_user
    VCR.use_cassette("login_user", record: :once, match_requests_on: [:host, :path]) do
      user = ::Openfoodfacts::User.login("wrong", "absolutely")
      assert_nil user
    end
  end

  # Product

  def test_it_returns_product_url
    product = ::Openfoodfacts::Product.new(code: "3029330003533")
    assert_equal ::Openfoodfacts::Product.url(product.code, locale: 'ca'), product.url(locale: 'ca')
  end

  def test_it_fetches_product
    product_code = "3029330003533"

    VCR.use_cassette("fetch_product_#{product_code}", record: :once, match_requests_on: [:host, :path]) do
      product = ::Openfoodfacts::Product.new(code: product_code)
      product.fetch
      refute_empty product.brands_tags
    end
  end

  def test_it_get_product
    product_code = "3029330003533"
    
    VCR.use_cassette("product_#{product_code}", record: :once, match_requests_on: [:host, :path]) do
      assert_equal ::Openfoodfacts::Product.get(product_code).code, product_code
    end
  end

  def test_that_it_search
    term = "Chocolat"
    first_product = nil

    VCR.use_cassette("search_#{term}") do
      products = ::Openfoodfacts::Product.search(term, page_size: 42)
      first_product = products.first

      assert_match /#{term}/i, products.last["product_name"]
      assert_match /#{term}/i, ::Openfoodfacts::Product.search(term).last["product_name"]
      assert_equal products.size, 42
    end

    VCR.use_cassette("search_#{term}_1_000_000") do
      refute_equal ::Openfoodfacts::Product.search(term, page: 2).first.code, first_product.code
    end
  end

=begin
  # Test disable in order to wait for a dedicated test account to not alter real data
  def test_it_updates_product
    product_code = "3029330003533"
    product = ::Openfoodfacts::Product.new(code: product_code)
    product_last_modified_t = nil

    VCR.use_cassette("fetch_product_#{product_code}", record: :all, match_requests_on: [:host, :path]) do
      product.fetch
      product_last_modified_t = product.last_modified_t
    end

    VCR.use_cassette("update_product_#{product_code}", record: :all, match_requests_on: [:host, :path]) do
      product.update # Empty update are accepted, allow testing without altering data.
    end

    VCR.use_cassette("refetch_product_#{product_code}", record: :all, match_requests_on: [:host, :path]) do
      product.fetch
    end

    refute_equal product_last_modified_t, product.last_modified_t
  end
=end

end
