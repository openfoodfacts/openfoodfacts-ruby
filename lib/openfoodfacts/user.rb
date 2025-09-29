# frozen_string_literal: true

require 'net/http'

module Openfoodfacts
  class User < Hashie::Mash
    class << self
      # Login
      #
      def login(user_id, password, locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        path = 'cgi/session.pl'
        uri = URI("https://#{locale}.#{domain}/#{path}")
        params = {
          'jqm' => '1',
          'user_id' => user_id,
          'password' => password
        }

        response = Net::HTTP.post_form(uri, params)
        return nil if response.code != '200'

        data = JSON.parse(response.body)

        return unless data['user_id']

        data.merge!(password: password)
        new(data)
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
