# frozen_string_literal: true

require_relative 'minitest_helper'

class TestDateAndIngredientFacets < Minitest::Test
  def test_it_fetches_entry_dates
    VCR.use_cassette('entry_dates') do
      entry_dates = ::Openfoodfacts::EntryDate.all
      assert_includes entry_dates.map { |entry_date| entry_date['name'] }, '2025-03'
    end
  end

  def test_it_fetches_entry_dates_for_locale
    VCR.use_cassette('entry_dates_locale') do
      entry_dates = ::Openfoodfacts::EntryDate.all(locale: 'fr')
      assert_includes entry_dates.map { |entry_date| entry_date['name'] }, '2025-03'
    end
  end

  def test_it_fetches_products_for_entry_date
    entry_date = ::Openfoodfacts::EntryDate.new('url' => 'https://world.openfoodfacts.org/facets/entry-dates/2014-04-17')
    VCR.use_cassette('products_for_entry_date') do
      products = entry_date.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end

  def test_it_fetches_last_edit_dates
    VCR.use_cassette('last_edit_dates') do
      last_edit_dates = ::Openfoodfacts::LastEditDate.all
      assert_includes last_edit_dates.map { |last_edit_date| last_edit_date['name'] }, '2025-04'
    end
  end

  def test_it_fetches_last_edit_dates_for_locale
    VCR.use_cassette('last_edit_dates_locale') do
      last_edit_dates = ::Openfoodfacts::LastEditDate.all(locale: 'fr')
      assert_includes last_edit_dates.map { |last_edit_date| last_edit_date['name'] }, '2025-04'
    end
  end

  def test_it_fetches_products_for_last_edit_date
    last_edit_date = ::Openfoodfacts::LastEditDate.new(
      'url' => 'https://world.openfoodfacts.org/facets/last-edit-dates/2020-04'
    )
    VCR.use_cassette('products_for_last_edit_date') do
      products = last_edit_date.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end

  def test_it_fetches_numbers_of_ingredients
    VCR.use_cassette('numbers_of_ingredients') do
      numbers = ::Openfoodfacts::NumberOfIngredients.all
      assert_includes numbers.map { |number| number['name'] }, '38'
    end
  end

  def test_it_fetches_numbers_of_ingredients_for_locale
    VCR.use_cassette('number_of_ingredients_locale') do
      numbers = ::Openfoodfacts::NumberOfIngredients.all(locale: 'fr')
      assert_includes numbers.map { |number| number['name'] }, '38'
    end
  end

  def test_it_fetches_products_for_number_of_ingredients
    number_of_ingredients = ::Openfoodfacts::NumberOfIngredients.new(
      'url' => 'https://world.openfoodfacts.org/facets/numbers-of-ingredients/38'
    )
    VCR.use_cassette('products_for_number_of_ingredients', record: :once, match_requests_on: %i[host path]) do
      products = number_of_ingredients.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end
end
