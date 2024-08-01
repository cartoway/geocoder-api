source 'https://rubygems.org'
ruby '>= 3'

gem 'rack'
gem 'rake'
gem 'puma'
gem 'rack-cors'
gem 'rack-server-pages'

gem 'grape'
gem 'grape_logging'
gem 'grape-entity'
gem 'grape-swagger'
gem 'grape-swagger-entity'

gem 'rack-contrib'
gem 'rest-client'
gem 'border_patrol'
gem 'activesupport'
gem 'actionpack'
gem 'rexml'

gem 'grape-erb'
# Extra : Implementing autocomplete url to here and google_places_search
gem 'geocoder'
gem 'sqlite3'
gem 'redis-activesupport'

gem 'stackprof'
gem 'sentry-ruby'
gem 'sentry-rails'

group :test do
  gem 'rack-test'
  gem 'minitest'
  gem 'minitest-focus'
  gem 'minitest-reporters'
  gem 'simplecov', require: false
  gem 'fakeredis'
end

group :development, :test do
  gem 'byebug'
  gem 'rubocop'
  gem 'redis', '< 5' # redis-store is buggy with redis 5 https://github.com/redis-store/redis-store/issues/358
end
