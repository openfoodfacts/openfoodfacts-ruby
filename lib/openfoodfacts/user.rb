require 'net/http'

module Openfoodfacts
  class User < Hashie::Mash

    class << self

      # Login
      # WARNING SECURITY: It is not made throught HTTPS Secure so password can be read on the way.
      #
      def login(user_id, password, locale: DEFAULT_LOCALE, domain: DEFAULT_DOMAIN)
        path = 'cgi/session.pl'
        uri = URI("http://#{locale}.#{domain}/#{path}")
        params = {
          "jqm" => "1",
          "user_id" => user_id,
          "password" => password
        }

        response = Net::HTTP.post_form(uri, params)
        data = JSON.parse(response.body)

        if data['user_id']
          data.merge!(password: password)
          new(data)
        end
      end

    end

    # Login
    #
    def login(locale: DEFAULT_LOCALE)
      if user = self.class.login(self.user_id, self.password, locale: locale)
        self.name = user.name
        self
      end
    end

  end
end
