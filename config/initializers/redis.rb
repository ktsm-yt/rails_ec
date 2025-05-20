Rails.application.config.redis = {
  url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/0' }
}
