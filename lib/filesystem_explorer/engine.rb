module FilesystemExplorer
  class Engine < ::Rails::Engine
    isolate_namespace FilesystemExplorer

    def self.filesystem_explorer_route_options
      @@filesystem_explorer_route_options ||= {}
    end
  end
end
