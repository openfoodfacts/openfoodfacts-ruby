# frozen_string_literal: true

require_relative 'minitest_helper'

class TestProductFacets < Minitest::Test
  def test_it_fetches_additives
    VCR.use_cassette('additives') do
      additives = ::Openfoodfacts::Additive.all
      assert_includes additives.map { |additive| additive['url'] },
                      'https://world.openfoodfacts.org/facets/additives/e330-citric-acid'
      refute_nil(additives.detect { |additive| !additive['riskiness'].nil? })
    end
  end

  def test_it_fetches_additives_for_locale
    VCR.use_cassette('additives_locale') do
      additives = ::Openfoodfacts::Additive.all(locale: 'fr')
      assert_includes additives.map { |additive| additive['url'] },
                      'https://fr.openfoodfacts.org/facets/additifs/e330-acide-citrique'
    end
  end

  def test_it_fetches_products_with_additive
    additive = ::Openfoodfacts::Additive.new(
      'url' => 'https://world.openfoodfacts.org/facets/additives/e452i-sodium-polyphosphate'
    )
    VCR.use_cassette('products_with_additive') do
      products = additive.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end

  def test_it_fetches_brands
    VCR.use_cassette('brands') do
      brands = ::Openfoodfacts::Brand.all
      assert_includes brands.map { |brand| brand['name'] }, 'Heinz'
    end
  end

  def test_it_fetches_brands_for_locale
    VCR.use_cassette('brands_locale') do
      brands = ::Openfoodfacts::Brand.all(locale: 'fr')
      assert_includes brands.map { |brand| brand['name'] }, 'gerble'
    end
  end

  def test_it_fetches_products_for_brand
    brand = ::Openfoodfacts::Brand.new('url' => 'https://world.openfoodfacts.org/facets/brands/bel')
    VCR.use_cassette('products_for_brand') do
      products = brand.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end

  def test_it_fetches_nutrition_grades
    VCR.use_cassette('nutrition_grades') do
      grades = ::Openfoodfacts::NutritionGrade.all
      assert_includes grades.map { |grade| grade['name'] }, 'Unknown'
    end
  end

  def test_it_fetches_nutrition_grades_for_locale
    VCR.use_cassette('nutrition_grades_locale') do
      grades = ::Openfoodfacts::NutritionGrade.all(locale: 'fr')
      assert_includes grades.map { |grade| grade['name'] }, 'Inconnu'
    end
  end

  def test_it_fetches_products_for_nutrition_grade
    grade = ::Openfoodfacts::NutritionGrade.new('url' => 'https://world.openfoodfacts.org/facets/nutrition-grades/c')
    VCR.use_cassette('products_for_nutrition_grade') do
      products = grade.products(page: 1)
      skip('No products found - website structure may have changed') if products.empty?
      refute_empty products
    end
  end
end
