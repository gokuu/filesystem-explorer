module FilesystemExplorer
  module ApplicationHelper
    def breakdown_path(path)
      paths = [path]

      while path = path.parent
        paths.unshift path
      end

      paths
    end

    def method_missing(method, *args, &block)
      if (method.to_s.end_with?('_path') || method.to_s.end_with?('_url')) && main_app.respond_to?(method)
        main_app.send(method, *args)
      else
        super
      end
    end
  end
end