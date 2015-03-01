require 'minitest_helper'

class TestOpenfoodfacts < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Openfoodfacts::VERSION
  end

  def test_it_fetches_product
    VCR.use_cassette("index") do
      locales = ::Openfoodfacts::locales
      assert_includes locales, "world"
      assert_includes locales, "fr"
      assert_includes locales, "be-fr"
    end
  end

  def test_it_fetches_product
    product_code = "3029330003533"
    VCR.use_cassette("product_#{product_code}") do
      assert_equal ::Openfoodfacts.product(product_code).code, product_code
    end
  end
end
