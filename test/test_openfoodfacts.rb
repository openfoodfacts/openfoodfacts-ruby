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

  def test_it_fetches_product
    product_code = "3029330003533"
    
    VCR.use_cassette("product_#{product_code}", record: :once, match_requests_on: [:host, :path]) do
      assert_equal ::Openfoodfacts::Product.get(product_code).code, product_code
    end
    VCR.use_cassette("product_#{product_code}", record: :once, match_requests_on: [:host, :path]) do
      #assert_equal ::Openfoodfacts.product(product_code).code, product_code # Backward compatibility
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

end
