# OpenFoodFacts

[![Gem Version](https://badge.fury.io/rb/openfoodfacts.svg)](http://badge.fury.io/rb/openfoodfacts)
[![Build Status](https://travis-ci.org/openfoodfacts/openfoodfacts-ruby.svg?branch=master)](https://travis-ci.org/openfoodfacts/openfoodfacts-ruby)
[![Dependency Status](https://gemnasium.com/openfoodfacts/openfoodfacts-ruby.svg)](https://gemnasium.com/openfoodfacts/openfoodfacts-ruby)
[![Code Climate](https://codeclimate.com/github/openfoodfacts/openfoodfacts-ruby/badges/gpa.svg)](https://codeclimate.com/github/openfoodfacts/openfoodfacts-ruby)
[![Coverage Status](https://coveralls.io/repos/openfoodfacts/openfoodfacts-ruby/badge.svg)](https://coveralls.io/r/openfoodfacts/openfoodfacts-ruby)
[![Documentation](http://inch-ci.org/github/openfoodfacts/openfoodfacts-ruby.svg?branch=master)](http://inch-ci.org/github/openfoodfacts/openfoodfacts-ruby)

API Wrapper for [OpenFoodFacts](https://openfoodfacts.org/), the open database about food.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openfoodfacts'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install openfoodfacts

## Models

All data is available for World, French, UK and US version for now. You should update the gem page URLs mapping for others.

- Additive
- Brand
- Category
- City
- Contributor
- Country
- Faq
- IngredientThatMayBeFromPalmOil
- Label
- Locale
- ManufacturingPlace
- Origin
- PackagerCode
- Packaging
- Press
- Product
- ProductState
- PurchasePlace
- Store
- Trace
- User

## Usage

```ruby
require 'openfoodfacts'

# Browse a product

code = "3029330003533"
product = Openfoodfacts::Product.get(code, locale: 'fr')

product.product_name
# => "Crousti Moelleux Complet"

product.nutriments.to_hash
# => {"sodium"=>"0.44", "sugars"=>6.5, "fat_unit"=>"g", "carbohydrates_unit"=>"g", "proteins_unit"=>"g", "nutrition-score-fr_100g"=>-2, "fat"=>2.5, "proteins_serving"=>12.8, "sodium_serving"=>0.535, "salt"=>1.1176, "proteins"=>10.5, "nutrition-score-uk_serving"=>-2, "nutrition-score-fr"=>-2, "fat_serving"=>3.04, "sugars_unit"=>"g", "sugars_100g"=>"6.5", "sodium_unit"=>"g", "saturated-fat_unit"=>"g", "saturated-fat_serving"=>0.608, "sodium_100g"=>0.44, "fiber_unit"=>"g", "energy"=>1067, "energy_unit"=>"kJ", "sugars_serving"=>7.9, "carbohydrates_100g"=>44, "nutrition-score-uk"=>-2, "proteins_100g"=>10.5, "fiber_serving"=>7.29, "carbohydrates_serving"=>53.5, "nutrition-score-fr_serving"=>-2, "energy_serving"=>1300, "fat_100g"=>"2.5", "saturated-fat_100g"=>"0.5", "nutrition-score-uk_100g"=>-2, "fiber"=>6, "salt_serving"=>1.36, "salt_100g"=>"1.1176", "carbohydrates"=>44, "fiber_100g"=>6, "energy_100g"=>1067, "saturated-fat"=>0.5}

# Update product

user = Openfoodfacts::User.login("USERNAME", "PASSWORD")
if user
    product.brands = "Jacquet"
    product.update
    # true
end

# Search products

products = Openfoodfacts::Product.search("Chocolate", locale: 'world', page_size: 3)
# => [#<Openfoodfacts::Product _id="3045140105502" code="3045140105502" id="3045140105502" image_small_url="http://en.openfoodfacts.org/images/products/304/514/010/5502/front.7.100.jpg" lc="en" product_name="Milka au lait du Pays Alpin">, #<Openfoodfacts::Product _id="3046920028363" code="3046920028363" id="3046920028363" image_small_url="http://en.openfoodfacts.org/images/products/304/692/002/8363/front.5.100.jpg" lc="en" product_name="Tableta de chocolate negro \"Lindt Excellence\" 85% cacao">, #<Openfoodfacts::Product _id="3046920029759" code="3046920029759" id="3046920029759" image_small_url="http://en.openfoodfacts.org/images/products/304/692/002/9759/front.9.100.jpg" lc="en" product_name="Tableta de chocolate negro \"Lindt Excellence\" 90% cacao">]

# You might need to fetch full product data from results

products.first.fetch

# By product state

product_states = Openfoodfacts::ProductState.all
product_states.last.products

# Config

Openfoodfacts::Locale.all
# => ["ad", "ad-es", "ad-fr", "ad-pt", "ae", "al", "am", "ar", "at", "au", "ax", "az", "bd", "be", "be-de", "be-fr", "bf", "bg", "bi", "bi-rn", "bn", "br", "by", "by-be", "bz", "ca", "ca-fr", "cg", "ch", "ch-fr", "ch-it", "ci", "cl", "cn", "co", "cr", "cu", "cy", "cy-tr", "cz", "de", "dk", "do", "dz", "dz-fr", "ec", "eg", "es", "es-ca", "es-eu", "es-gl", "fi", "fi-sv", "fr", "ga", "gf", "gn", "gp", "gr", "hk", "hr", "hu", "id", "ie", "ie-ga", "il", "il-ar", "il-ru", "in", "iq", "iq-ku", "ir", "is", "it", "jp", "ke", "ke-sw", "kh", "kr", "kw", "kz", "kz-kk", "lb", "lk", "lk-ta", "lu", "lu-de", "lu-lb", "lv", "ma", "ma-es", "ma-fr", "mc", "md", "mf", "ml", "mn", "mo", "mo-zh", "mq", "mr", "mt", "mt-mt", "mu", "mx", "my", "nc", "nl", "no", "nz", "nz-mi", "pa", "pe", "pf", "ph", "ph-tl", "pl", "pm", "pt", "qa", "re", "ro", "rs", "ru", "sa", "se", "sg", "sg-ms", "sg-ta", "sg-zh", "si", "sk", "sn", "sy", "th", "tn", "tr", "tw", "tz", "tz-sw", "ua", "uk", "us", "ve", "vn", "vu", "vu-bi", "world", "ye", "yt", "za", "za-af", "za-nr", "za-ss", "za-st", "za-tn", "za-ts", "za-ve", "za-xh", "za-zu"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/openfoodfacts/openfoodfacts-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
