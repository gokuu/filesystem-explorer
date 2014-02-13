require "filesystem_explorer/engine"
require 'filesystem_explorer/filesystem_item'
require 'filesystem_explorer/filesystem_route_options'
require 'filesystem_explorer/router'

module FilesystemExplorer
  def self.routes ; @routes ||= [] ; end
end
