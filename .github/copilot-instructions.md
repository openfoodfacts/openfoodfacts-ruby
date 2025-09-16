# OpenFoodFacts Ruby SDK

OpenFoodFacts Ruby SDK is a Ruby gem that provides API access to the Open Food Facts database, the open database about food. The gem includes models for Product, Locale, User and many other food-related entities.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Setup
- Install Ruby 2.5 or higher (project supports Ruby 2.5-3.3, current development uses Ruby 3.3.6)
- Install Bundler for dependency management:
  ```bash
  gem install bundler --user-install
  export PATH="$PATH:$HOME/.local/share/gem/ruby/3.2.0/bin"
  ```
- Configure Bundler to install gems to user directory:
  ```bash
  bundle config path ~/.gems
  ```

### Bootstrap, Build, and Test
- **Install dependencies**: `bundle install` -- takes 5-15 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
- **Run tests**: `bundle exec rake test` -- takes 2-3 seconds. NEVER CANCEL. Set timeout to 30+ seconds.
  - NOTE: Tests may have failures due to external API dependencies being unreachable in restricted environments
- **Build gem**: `bundle exec rake build` -- takes 1 second. NEVER CANCEL. Set timeout to 30+ seconds.
- **Install gem locally**: `bundle exec rake install:local` -- takes 1-2 seconds.

### Development Commands
- **List all rake tasks**: `bundle exec rake -T`
- **Launch console**: `bundle exec rake console` (may hang, use `bundle exec irb -r openfoodfacts` instead)
- **Clean build artifacts**: `bundle exec rake clobber`

## Validation

### Always Test Core Functionality
After making changes, always validate by running:
```ruby
# Create a test script to verify basic functionality
require 'openfoodfacts'
puts "Version: #{Openfoodfacts::VERSION}"
product = Openfoodfacts::Product.new(code: "test")
puts "Product URL: #{Openfoodfacts::Product.url('test', locale: 'world')}"
```

### Linting
- RuboCop is used for code style but is not included in development dependencies
- Install and run manually: 
  ```bash
  gem install rubocop --user-install
  rubocop lib/openfoodfacts.rb
  ```
- CI pipeline includes RuboCop analysis (see `.github/workflows/rubocop-analysis.yml`)

### Manual Testing Scenarios
- Always test that the library loads: `require 'openfoodfacts'`
- Verify version access: `Openfoodfacts::VERSION` should return current version (0.6.2)
- Test Product model instantiation: `Openfoodfacts::Product.new(code: "test")`
- Verify URL generation: `Openfoodfacts::Product.url("123", locale: "world")`

## Common Tasks

### Repo Structure
```
.
├── .github/           # GitHub workflows and configs
├── lib/
│   ├── openfoodfacts.rb           # Main module file
│   └── openfoodfacts/
│       ├── product.rb             # Core Product model
│       ├── locale.rb              # Locale handling
│       ├── user.rb                # User authentication
│       └── [27 other models]      # Brand, Category, etc.
├── test/
│   ├── minitest_helper.rb         # Test configuration
│   ├── test_openfoodfacts.rb      # Main test file
│   └── fixtures/                  # VCR test fixtures
├── Gemfile                        # Dependencies
├── openfoodfacts.gemspec          # Gem specification
├── Rakefile                       # Build tasks
└── README.md                      # Usage documentation
```

### Key Files to Know
- **Main entry point**: `lib/openfoodfacts.rb` - defines module and requires all classes
- **Primary model**: `lib/openfoodfacts/product.rb` - core Product class with API methods
- **Version**: `lib/openfoodfacts/version.rb` - contains `VERSION = "0.6.2"`
- **Tests**: `test/test_openfoodfacts.rb` - comprehensive test suite with VCR fixtures
- **CI workflows**: 
  - `.github/workflows/ruby.yml` - runs tests on Ruby 2.5-3.3
  - `.github/workflows/rubocop-analysis.yml` - static code analysis

### Dependencies
- **Runtime**: `hashie` (>= 3.4, < 6.0), `nokogiri` (~> 1.7)
- **Development**: `minitest`, `vcr`, `webmock`, `rake`, `bundler`
- **Ruby requirement**: >= 2.5

### API and Network Dependencies
- The gem connects to `openfoodfacts.org` for live data
- Tests use VCR (Video Cassette Recorder) to mock HTTP requests
- In network-restricted environments, only basic functionality (class loading, URL generation) can be tested
- Real API calls require setting `OPENFOODFACTS_USER_AGENT` environment variable

### Common Issues
- **Permission errors during gem install**: Use `--user-install` flag and update PATH
- **Bundle install fails**: Configure `bundle config path ~/.gems` first
- **Test failures**: Expected when network access is restricted; focus on gem build success
- **RuboCop not found**: Install separately with `gem install rubocop --user-install`

### Development Workflow
1. Make changes to lib/ files
2. Run `bundle exec rake build` to verify gem builds
3. Run `bundle exec rake test` to run test suite  
4. Create simple validation script to test core functionality
5. Run RuboCop for style checking (if installed)
6. Always test that the gem loads and basic models work

This gem provides a Ruby interface to the Open Food Facts database with models for products, locales, users, and food-related metadata. Changes should maintain backward compatibility and follow the existing patterns in the codebase.