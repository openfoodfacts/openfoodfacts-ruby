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

  def test_it_returns_product_weburl
    product = ::Openfoodfacts::Product.new(code: "3029330003533")
    assert_equal "https://world.openfoodfacts.org/product/#{product.code}", product.weburl(locale: 'world')
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

      assert_match(/#{term}/i, products.last["product_name"])
      assert_match(/#{term}/i, ::Openfoodfacts::Product.search(term).last["product_name"])
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


  # Additives

  def test_it_fetches_additives
    VCR.use_cassette("additives") do
      additives = ::Openfoodfacts::Additive.all(locale: 'fr') # FR to have riskiness
      assert_equal "https://fr.openfoodfacts.org/additif/e330-acide-citrique", additives.first.url
      refute_nil additives.detect { |additive| !additive['riskiness'].nil? }
    end
  end

  def test_it_fetches_additives_for_locale
    VCR.use_cassette("additives_locale") do
      additives = ::Openfoodfacts::Additive.all(locale: 'fr')
      assert_equal "https://fr.openfoodfacts.org/additif/e330-acide-citrique", additives.first.url
    end
  end

  def test_it_fetches_products_with_additive
    additive = ::Openfoodfacts::Additive.new("url" => "https://world.openfoodfacts.org/additive/e452i-sodium-polyphosphate")
    VCR.use_cassette("products_with_additive") do
      products_with_additive = additive.products(page: -1)
      refute_empty products_with_additive
    end
  end

  # Brands

  def test_it_fetches_brands
    VCR.use_cassette("brands") do
      brands = ::Openfoodfacts::Brand.all
      assert_includes brands.map { |brand| brand['name'] }, "Carrefour"
    end
  end

  def test_it_fetches_brands_for_locale
    VCR.use_cassette("brands_locale") do
      brands = ::Openfoodfacts::Brand.all(locale: 'fr')
      assert_includes brands.map { |brand| brand['name'] }, "Loue"
    end
  end

  def test_it_fetches_products_for_brand
    brand = ::Openfoodfacts::Brand.new("url" => "https://world.openfoodfacts.org/brand/bel")
    VCR.use_cassette("products_for_brand") do
      products_for_brand = brand.products(page: -1)
      refute_empty products_for_brand
    end
  end

  # Languages

  def test_it_fetches_languages
    VCR.use_cassette("languages") do
      languages = ::Openfoodfacts::Language.all
      assert_includes languages.map { |language| language['name'] }, "French"
    end
  end

  def test_it_fetches_languages_for_locale
    VCR.use_cassette("languages_locale") do
      languages = ::Openfoodfacts::Language.all(locale: 'fr')
      assert_includes languages.map { |language| language['name'] }, "Anglais"
    end
  end

  def test_it_fetches_products_for_language
    language = ::Openfoodfacts::Language.new("url" => "https://world.openfoodfacts.org/language/french")
    VCR.use_cassette("products_for_language") do
      products_for_language = language.products(page: -1)
      refute_empty products_for_language
    end
  end

  # Product states

  def test_it_fetches_product_states
    VCR.use_cassette("product_states") do
      product_states = ::Openfoodfacts::ProductState.all
      assert_equal "https://world.openfoodfacts.org/state/empty", product_states.last.url
    end
  end

  def test_it_fetches_product_states_for_locale
    VCR.use_cassette("product_states_locale") do
      product_states = ::Openfoodfacts::ProductState.all(locale: 'fr')
      assert_equal "https://fr.openfoodfacts.org/etat/vide", product_states.last.url
    end
  end

  def test_it_fetches_products_for_state
    product_state = ::Openfoodfacts::ProductState.new("url" => "https://world.openfoodfacts.org/state/photos-uploaded", "products_count" => 22)
    VCR.use_cassette("products_for_state") do
      products_for_state = product_state.products(page: -1)
      refute_empty products_for_state
    end
  end

  # FAQ

  def test_it_fetches_faq
    VCR.use_cassette("faq") do
      refute_empty ::Openfoodfacts::Faq.items(locale: 'fr')
    end
  end

  # Mission

  def test_it_fetches_missions
    VCR.use_cassette("missions") do
      refute_empty ::Openfoodfacts::Mission.all(locale: 'fr')
    end
  end

  def test_it_fetches_mission
    VCR.use_cassette("mission", record: :once, match_requests_on: [:host, :path]) do
      mission = ::Openfoodfacts::Mission.new(url: "https://fr.openfoodfacts.org/mission/informateur-100-produits")
      mission.fetch
      refute_empty mission.users
    end
  end

  # Press

  def test_it_fetches_press
    VCR.use_cassette("press") do
      refute_empty ::Openfoodfacts::Press.items(locale: 'fr')
    end
  end

end
