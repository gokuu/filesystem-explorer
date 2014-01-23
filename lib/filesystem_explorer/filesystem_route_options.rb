module FilesystemExplorer
  class FilesystemRouteOptions
    %w(as url path).each do |method|
      attr_reader :"#{method}"
      instance_variable_set :"@#{method}", nil

      define_method(method) do |value = nil|
        instance_variable_set :"@#{method}", value if value
        instance_variable_get :"@#{method}"
      end
    end
  end
end