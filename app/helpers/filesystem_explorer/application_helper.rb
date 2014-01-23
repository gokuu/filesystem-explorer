module FilesystemExplorer
  module ApplicationHelper
    def breakdown_path(path)
      Rails.logger.ap path
      path_array = path.path.split('/')

      return [path] if path_array.empty?

      paths = (0...path_array.length).map do |index|
        FilesystemItem.new(path_array[0..index].join('/'), { root: path.root})
      end.unshift(FilesystemItem.new('/', { root: path.root}))

      Rails.logger.ap paths
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