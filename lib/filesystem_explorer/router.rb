module ActionDispatch
  module Routing
    class Mapper
      def filesystem_routes(&block)
        config_file_path = Rails.root.join('config', 'filesystem_explorer.yml')

        if File.exists?(config_file_path)
          config_data = YAML.load_file(config_file_path)

          config_data.each do |route|
            filesystem_explorer path: route[:path] || route['path'], as: route[:as] || route['as'], url: route[:url] || route['url']
          end
        end

        block.call($filesystem_explorer_route_options || {}) if block
      end

      def filesystem_explorer(options = {}, &block)
        route_config = FilesystemExplorer::FilesystemRouteOptions.new

        # Copy all applicable options from the parameter hash to the object
        %w(path as url).each do |option|
          route_config.send option, options[option.to_sym] if options[option.to_sym] && route_config.respond_to?(option)
        end

        route_config.instance_eval &block if block

        $filesystem_explorer_route_options ||= {}
        $filesystem_explorer_route_options[route_config.url] ||= route_config

        FilesystemExplorer.routes << route_config

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