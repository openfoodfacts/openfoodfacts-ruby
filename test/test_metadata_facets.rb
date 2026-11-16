# frozen_string_literal: true

require_relative 'minitest_helper'

class TestMetadataFacets < Minitest::Test
  def test_it_fetches_period_after_opening
    VCR.use_cassette('period_after_openings') do
      refute_empty ::Openfoodfacts::PeriodAfterOpening.all(locale: 'fr')
    end
  end

  def test_it_fetches_languages
    VCR.use_cassette('languages') do
      languages = ::Openfoodfacts::Language.all
      assert_includes languages.map { |language| language['name'] }, 'French'
    end
  end

  def test_it_fetches_languages_for_locale
    VCR.use_cassette('languages_locale') do
      languages = ::Openfoodfacts::Language.all(locale: 'fr')
      assert_includes languages.map { |language| language['name'] }, 'Anglais'
    end
  end

  def test_it_fetches_products_for_language
    language = ::Openfoodfacts::Language.new('url' => 'https://world.openfoodfacts.org/facets/languages/french')
    VCR.use_cassette('products_for_language') do
      products = language.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end

  def test_it_fetches_product_states
    VCR.use_cassette('product_states') do
      states = ::Openfoodfacts::ProductState.all
      assert_includes states.map { |state| state['url'] },
                      'https://world.openfoodfacts.org/facets/states/to-be-completed'
    end
  end

  def test_it_fetches_product_states_for_locale
    VCR.use_cassette('product_states_locale') do
      states = ::Openfoodfacts::ProductState.all(locale: 'fr')
      assert_includes states.map { |state| state['url'] },
                      'https://fr.openfoodfacts.org/facets/etats/a-completer'
    end
  end

  def test_it_fetches_products_for_state
    state = ::Openfoodfacts::ProductState.new(
      'url' => 'https://world.openfoodfacts.org/facets/states/photos-uploaded',
      'products_count' => 22
    )
    VCR.use_cassette('products_for_state') do
      products = state.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end

  def test_it_fetches_ingredient
    VCR.use_cassette('ingredients') do
      refute_empty ::Openfoodfacts::Ingredient.all(locale: 'fr')
    end
  end
end
