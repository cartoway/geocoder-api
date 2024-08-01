if ENV['SENTRY_DSN']
  Sentry.init { |config|
    config.dsn = ENV['SENTRY_DSN']
  }
end
