module FilesystemExplorer
  class ApplicationController < ::ApplicationController
    ActionController::Streaming::X_SENDFILE_HEADER = 'X-Accel-Redirect'

    attr_reader :route

    helper_method :current_filesystem_explorer_path, :filesystem_explorer_root_path, :filesystem_explorer_root_name

    before_filter :get_engine_configuration_options

    def index
      @path = FilesystemExplorer::FilesystemItem.new(route.path, %Q[#{params[:path]}#{".#{params[:format]}" if params[:format]}])
      @path.parent.instance_exec { @is_parent = true } if @path.parent

      render @path.exists? ? :index : :not_found
    end

    def download
      @path = FilesystemExplorer::FilesystemItem.new(File.join('/', %Q[#{params[:path]}#{".#{params[:format]}" if params[:format]}]), root: route.path)
      send_file @path.full_path, disposition: :attachment, x_sendfile: true
    end

    def current_filesystem_explorer_path ; return @path ; end

    def filesystem_explorer_root_path(as = nil)
      options = as.nil? ? route : get_engine_configuration_options_by_as(as)

      return @filesystem_explorer_root_path ||= Rails.application.routes.url_helpers.send("#{options.as}_path")
    end

    def filesystem_explorer_root_name(as = nil)
      options = as.nil? ? route : get_engine_configuration_options_by_as(as)

      return @filesystem_explorer_root_name ||= options.as.to_s.humanize
    end

    private

      def get_engine_configuration_options
        FilesystemExplorer::Engine.filesystem_explorer_route_options.each do |path, options|
          @route = options and break if request.path =~ %r(^#{path})
        end
      end

      def get_engine_configuration_options_by_as(as)
        FilesystemExplorer::Engine.filesystem_explorer_route_options.each do |path, options|
          return options if options.as.to_sym == as.to_sym
        end

        return nil
      end
  end
end
