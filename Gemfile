source 'https://rubygems.org'
ruby '>= 3'

gem 'puma'
gem 'rack'
gem 'rack-cors'
gem 'rack-server-pages'
gem 'rake'

gem 'grape'
gem 'grape-entity'
gem 'grape_logging'
gem 'grape-swagger'
gem 'grape-swagger-entity'

gem 'actionpack'
gem 'activesupport'
gem 'border_patrol'
gem 'rack-contrib'
gem 'rest-client'
gem 'rexml'

gem 'grape-erb'
# Extra : Implementing autocomplete url to here and google_places_search
gem 'geocoder'
gem 'redis-activesupport'
gem 'sqlite3'

gem 'sentry-ruby'

group :test do
  gem 'fakeredis'
  gem 'minitest'
  gem 'minitest-focus'
  gem 'minitest-reporters'
  gem 'rack-test'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'redis', '< 5' # redis-store is buggy with redis 5 https://github.com/redis-store/redis-store/issues/358
  gem 'rubocop'
  gem 'rubocop-policy', github: 'cartoway/rubocop-policy'
end
