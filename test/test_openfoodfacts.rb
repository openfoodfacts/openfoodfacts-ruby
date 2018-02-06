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
      assert_includes locales.map { |locale| locale['code'] }, "gd"
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
    term = "coca"
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
      additives = ::Openfoodfacts::Additive.all # World to have riskiness
      assert_includes additives.map { |additive| additive['url'] }, "https://world.openfoodfacts.org/additive/e330-citric-acid"
      refute_nil additives.detect { |additive| !additive['riskiness'].nil? }
    end
  end

  def test_it_fetches_additives_for_locale
    VCR.use_cassette("additives_locale") do
      additives = ::Openfoodfacts::Additive.all(locale: 'fr')
      assert_includes additives.map { |additive| additive['url'] }, "https://fr.openfoodfacts.org/additif/e330-acide-citrique"
    end
  end

  def test_it_fetches_products_with_additive
    additive = ::Openfoodfacts::Additive.new("url" => "https://world.openfoodfacts.org/additive/e452i-sodium-polyphosphate")
    VCR.use_cassette("products_with_additive") do
      products_with_additive = additive.products(page: 1)
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
      products_for_brand = brand.products(page: 1)
      refute_empty products_for_brand
    end
  end

  # Nutrition Grades

  def test_it_fetches_nutrition_grades
    VCR.use_cassette("nutrition_grades") do
      nutrition_grades = ::Openfoodfacts::NutritionGrade.all
      assert_includes nutrition_grades.map { |nutrition_grade| nutrition_grade['name'] }, "Unknown"
    end
  end

  def test_it_fetches_nutrition_grades_for_locale
    VCR.use_cassette("nutrition_grades_locale") do
      nutrition_grades = ::Openfoodfacts::NutritionGrade.all(locale: 'fr')
      assert_includes nutrition_grades.map { |nutrition_grade| nutrition_grade['name'] }, "Inconnu"
    end
  end

  def test_it_fetches_products_for_nutrition_grade
    nutrition_grade = ::Openfoodfacts::NutritionGrade.new("url" => "https://world.openfoodfacts.org/nutrition-grade/c")
    VCR.use_cassette("products_for_nutrition_grade") do
      products_for_nutrition_grade = nutrition_grade.products(page: 1)
      refute_empty products_for_nutrition_grade
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
      products_for_language = language.products(page: 1)
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
      products_for_state = product_state.products(page: 1)
      refute_empty products_for_state
    end
  end

  # Entry date

  def test_it_fetches_entry_dates
    VCR.use_cassette("entry_dates") do
      entry_dates = ::Openfoodfacts::EntryDate.all
      assert_includes entry_dates.map { |entry_date| entry_date['name'] }, "2017-03-09"
    end
  end

  def test_it_fetches_entry_dates_for_locale
    VCR.use_cassette("entry_dates_locale") do
      entry_dates = ::Openfoodfacts::EntryDate.all(locale: 'fr')
      assert_includes entry_dates.map { |entry_date| entry_date['name'] }, "2017-03-09"
    end
  end

  def test_it_fetches_products_for_entry_date
    entry_date = ::Openfoodfacts::EntryDate.new("url" => "https://world.openfoodfacts.org/entry-date/2014-04-17")
    VCR.use_cassette("products_for_entry_date") do
      products_for_entry_date = entry_date.products(page: 1)
      refute_empty products_for_entry_date
    end
  end

  # Last edit date

  def test_it_fetches_last_edit_dates
    VCR.use_cassette("last_edit_dates") do
      last_edit_dates = ::Openfoodfacts::LastEditDate.all
      assert_includes last_edit_dates.map { |last_edit_date| last_edit_date['name'] }, "2017-03-23"
    end
  end

  def test_it_fetches_last_edit_dates_for_locale
    VCR.use_cassette("last_edit_dates_locale") do
      last_edit_dates = ::Openfoodfacts::LastEditDate.all(locale: 'fr')
      assert_includes last_edit_dates.map { |last_edit_date| last_edit_date['name'] }, "2017-03-23"
    end
  end

  def test_it_fetches_products_for_last_edit_date
    last_edit_date = ::Openfoodfacts::LastEditDate.new("url" => "https://world.openfoodfacts.org/last-edit-date/2013-11-11")
    VCR.use_cassette("products_for_last_edit_date") do
      products_for_last_edit_date = last_edit_date.products(page: 1)
      refute_empty products_for_last_edit_date
    end
  end

  # Number of Ingredients

  def test_it_fetches_numbers_of_ingredients
    VCR.use_cassette("numbers_of_ingredients") do
      numbers_of_ingredients = ::Openfoodfacts::NumberOfIngredients.all
      assert_includes numbers_of_ingredients.map { |number_of_ingredients| number_of_ingredients['name'] }, "38"
    end
  end

  def test_it_fetches_numbers_of_ingredients_for_locale
    VCR.use_cassette("number_of_ingredients_locale") do
      numbers_of_ingredients = ::Openfoodfacts::NumberOfIngredients.all(locale: 'fr')
      assert_includes numbers_of_ingredients.map { |number_of_ingredients| number_of_ingredients['name'] }, "38"
    end
  end

  def test_it_fetches_products_for_number_of_ingredients
    number_of_ingredients = ::Openfoodfacts::NumberOfIngredients.new("url" => "https://world.openfoodfacts.org/number-of-ingredients/38")
    VCR.use_cassette("products_for_number_of_ingredients") do
      products_for_number_of_ingredients = number_of_ingredients.products(page: 1)
      refute_empty products_for_number_of_ingredients
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
      skip("Website have a bug with Missions page on https://fr.openfoodfacts.org/missions")
      refute_empty ::Openfoodfacts::Mission.all(locale: 'fr')
    end
  end

  def test_it_fetches_mission
    VCR.use_cassette("mission", record: :once, match_requests_on: [:host, :path]) do
      skip("Website have a bug with Mission page on https://fr.openfoodfacts.org/mission/informateur-100-produits")
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
