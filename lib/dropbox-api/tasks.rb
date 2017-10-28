module Dropbox
  module API

    class Tasks

      extend Rake::DSL if defined? Rake::DSL

      def self.install

        namespace :dropbox do
          desc "Authorize wizard for Dropbox API"
          task :authorize do
            require "oauth2"
            require "dropbox-api"
            require "cgi"
            print "Enter dropbox app key: "
            consumer_key = $stdin.gets.chomp
            print "Enter dropbox app secret: "
            consumer_secret = $stdin.gets.chomp

            Dropbox::API::Config.app_key    = consumer_key
            Dropbox::API::Config.app_secret = consumer_secret

            authorize_uri = ::Dropbox::API::OAuth2::AuthFlow.start

            puts "\nGo to this url and click 'Authorize' to get the token:"
            puts authorize_uri
            print "\nOnce you authorize the app on Dropbox, paste the code here and press enter:"
            code = $stdin.gets.chomp

            access_token = ::Dropbox::API::OAuth2::AuthFlow.finish(code)

            puts "\nAuthorization complete!:\n\n"
            puts "  Dropbox::API::Config.app_key    = '#{consumer_key}'"
            puts "  Dropbox::API::Config.app_secret = '#{consumer_secret}'"
            puts "  client = Dropbox::API::Client.new(:token  => '#{access_token.token}')"
            puts "\n"
          end

          desc <<-DESC
Creates an OAuth 2.0 access token from the supplied OAuth 1.0 token and secret.

Options:
* key -- The Dropbox developer app key (Required)
* token -- The OAuth 1.0 access token (Required)
* secret -- The OAuth 1.0 access token secret (Required)
DESC
          task :update_token do
            require 'json'

            key = ENV['key'].to_s
            if key.empty?
              puts 'Enter Dropbox developer app key: '
              key = $stdin.gets.chomp
            end
            raise 'Key is required' if key.empty?

            token = ENV['token'].to_s
            if token.empty?
              puts 'Enter OAuth 1.0 access token: '
              token = $stdin.gets.chomp
            end
            raise 'Token is required' if token.empty?

            secret = ENV['secret'].to_s
            if secret.empty?
              puts 'Enter OAuth 1.0 access token secret: '
              secret = $stdin.gets.chomp
            end
            raise 'Secret is required' if secret.empty?

            # For Dropbox API documentation, see:
            # https://www.dropbox.com/developers/documentation/http/documentation#auth-token-from_oauth1

            url = 'https://api.dropboxapi.com/2/auth/token/from_oauth1'
            data = {
              oauth1_token: token,
              oauth1_token_secret: secret
            }
            cmd = "curl --silent -X POST #{url} \
              --header 'Authorization: Basic #{key}' \
              --header 'Content-Type: application/json' \
              --data '#{data.to_json}'"
            result = %x[ #{cmd} ]
            hsh = JSON.parse(result, symbolize_names: true)
            begin
              new_token = hsh.fetch(:oauth2_token)
            rescue IndexError => e
              error = hsh.fetch(:error_summary, 'OAuth 2.0 token not returned')
              puts "\n  Error: #{error}\n\n"
              exit
            end

            puts "Update successful!\n\n"
            puts "  New OAuth 2.0 access token = #{new_token}\n\n"
          end

        end

      end

    end

  end
end
