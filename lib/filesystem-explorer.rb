require 'dragonfly'
require "filesystem_explorer/dragonfly_data_store"
require "filesystem_explorer/engine"
require 'filesystem_explorer/filesystem_item'
require 'filesystem_explorer/filesystem_route_options'
require 'filesystem_explorer/router'

# Configure Dragonfly
Dragonfly.app.configure do
  plugin :imagemagick

  secret "4257035eaa1fdf22788ecfe450f6e5c9ec733fb4f41591517c2a9d744f9ba620"

  url_format "/media/:job/:name"

  # datastore :file,
  #   root_path: Rails.root.join('public/system/dragonfly', Rails.env),
  #   server_root: Rails.root.join('public')
  datastore FilesystemExplorer::DragonflyDataStore.new
  # datastore :file
end

# Logger
Dragonfly.logger = Rails.logger

# # Mount as middleware
# Rails.application.middleware.use Dragonfly::Middleware

module FilesystemExplorer
  def self.routes ; @routes ||= [] ; end
end


