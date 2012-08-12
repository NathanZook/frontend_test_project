require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module DealSite
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.paths += Dir.glob(Rails.root.join *%w{app themes})
    config.assets.precompile = [Proc.new{ |path| File.extname(path).in?(%w{.js .css .png})}]
  end
end
