# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# 本番環境のみリダイレクト
if ENV['RACK_ENV'] == 'production'
  use Rack::Rewrite do
    r301 %r{.*}, 'https://www.yorisoi-note.com$&', if: Proc.new { |env|
      env['SERVER_NAME'] != 'www.yorisoi-note.com'
    }
  end
end

run Rails.application
Rails.application.load_server
