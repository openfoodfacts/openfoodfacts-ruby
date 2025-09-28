To release a new version:

1. Update the version number in `lib/openfoodfacts/version.rb`
2. Push your changes to the `main` branch
3. Release Please will automatically create a release pull request
4. Merge the release pull request to trigger automatic publishing to RubyGems via Trusted Publishers

The gem is automatically published to RubyGems when a release is created, using GitHub's Trusted Publishers feature for secure authentication without API keys.

