module ActionDispatch
  module Routing
    class Mapper
      def filesystem_explorer(options = {}, &block)
        route_config = FilesystemExplorer::FilesystemRouteOptions.new
        route_config.instance_eval &block if block

        $filesystem_explorer_route_options ||= {}
        $filesystem_explorer_route_options[route_config.url] ||= route_config

        Rails.application.routes.draw do
          # Download route
          route_options = { "#{route_config.url}/*path/download" => "filesystem_explorer/application#download" }
          route_options[:as] = :"#{route_config.as}_download" if route_config.as
          get route_options

          # Dynamic route
          route_options = { "#{route_config.url}/*path" => "filesystem_explorer/application#index" }
          get route_options

          # Root route
          route_options = { "#{route_config.url}" => "filesystem_explorer/application#index" }
          route_options[:as] = :"#{route_config.as}" if route_config.as
          get route_options
        end
      end
    end
  end
end