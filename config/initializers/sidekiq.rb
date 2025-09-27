# REDIS_TLS_URL を優先的に利用し、なければ REDIS_URL、それもなければローカルを使う
redis_url = ENV["REDIS_TLS_URL"] || ENV.fetch("REDIS_URL", "redis://localhost:6379")

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

# sidekiq-cronの設定
schedule_file = "config/schedule.yml"
Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
