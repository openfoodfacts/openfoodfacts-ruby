# frozen_string_literal: true

require 'net/http'

module Openfoodfacts
  # Represents an Open Food Facts user account.
  class User < Hashie::Mash
    class << self
      # Login
      #
      def login(user_id, password, locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        uri = URI("https://#{locale}.#{domain}/cgi/session.pl")
        response = Net::HTTP.post_form(uri, { 'jqm' => '1', 'user_id' => user_id, 'password' => password })
        return nil if response.code != '200'

        data = JSON.parse(response.body)
        return unless data['user_id']

        new(data.merge(password: password))
      end
    end

    # Login
    #
    def login(locale: DEFAULT_LOCALE)
      user = self.class.login(user_id, password, locale: locale)
      return unless user

      self.name = user.name
      self
    end
  end
end
