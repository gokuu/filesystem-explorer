module FilesystemExplorer
  class FilesystemItem
    attr_reader :root
    attr_reader :full_path
    attr_reader :kind

    def get_photo_thumbnail(thumbnail_size = '300x300')
      generate_photo_thumbnail! unless File.exists?(photo_thumbnail_path(thumbnail_size))
      photo_thumbnail_path.sub(File.join(Rails.root, 'public'), '')
    end

    def photo_thumbnail_path(thumbnail_size = '300x300')
      thumbnail_part = File.join(thumbnail_size, full_path).gsub(/[?!<>#^%@]/, '').tr(' ', '_').downcase
      @photo_thumbnail_path ||= File.join(Rails.root, 'public', 'photo_thumbnails', thumbnail_part)
    end

    def generate_photo_thumbnail!(thumbnail_size = '300x300')
      processor = Dragonfly.app.fetch_file(full_path).thumb(thumbnail_size)
      processor.to_file photo_thumbnail_path(thumbnail_size)
    end

    def initialize(root, relative_path, options = {})
      Rails.logger.ap ["options", root, relative_path, options]
      root = [root].flatten

      if root.count > 1
        relative_path = nil if File.expand_path(relative_path).gsub(/^#{Dir.pwd}\/?/, '').gsub(/^\d+\/?/, '').strip =~ /^\/?$/

        if relative_path.blank?
          initialize_for_multi_root(options.merge({ :roots => root }))
        else
          root.each { |r| relative_path = relative_path.gsub(/^#{r}\/?/, '') }
          initialize_for_multi_root_child(options.merge({
            :roots => root,
            :index => options[:index] || (relative_path =~ /^(\d+)/ && $1.to_i),
            :relative_path => relative_path
          }))
        end
      else
        if relative_path.blank?
          initialize_for_single_root(options.merge({ :root => root.first }))
        else
          initialize_for_single_root_child(options.merge({
            :root => root.first,
            :relative_path => relative_path
          }))
        end
      end
    end

    def initialize_for_multi_root(options)
      @root = options[:roots]
      @full_paths = @root.map { |r| File.expand_path(r) }
      @kind = options[:kind]
      @is_directory = @full_paths.all? { |p| File.directory?(p) }
      @modified_at = nil
      @size = nil
      @is_root = true
      @exists = @full_paths.all? { |p| File.exists?(p) }
      @is_multi_root = true

      load_type
    end

    def initialize_for_multi_root_child(options)
      @root = options[:roots]
      @index = options[:index]
      @path = options[:relative_path]
      @full_path = File.expand_path(File.join(@root[@index], options[:relative_path].gsub(/^#{options[:index]}\/?/, '')))
      @kind = options[:kind]
      @exists = File.exists?(@full_path)
      @name = File.basename(@full_path)
      @is_directory = @exists && File.directory?(@full_path)
      @modified_at = @exists && File.mtime(@full_path)
      @size = @exists && File.size(@full_path)
      @is_multi_root = true
      @is_root = false
      @parent = FilesystemItem.new(@root, build_path(@path, '..'), { :index => options[:index], kind: @kind })

      load_type
    end

    def initialize_for_single_root(options)
      @root = options[:root]
      @full_path = File.expand_path(@root)
      @kind = options[:kind]
      @path = '/'
      @is_directory = File.directory?(@full_path)
      @modified_at = File.mtime(@full_path)
      @size = File.size(@full_path)
      @is_root = true
      @exists = File.exists?(@full_path)
      @is_multi_root = false

      load_type
    end

    def initialize_for_single_root_child(options)
      @root = options[:root]
      @path = options[:relative_path]
      @full_path = File.expand_path(File.join(@root, @path))
      @kind = options[:kind]
      @name = File.basename(@full_path)
      @is_directory = File.directory?(@full_path)
      @modified_at = File.mtime(@full_path)
      @size = File.size(@full_path)
      @is_root = false
      @exists = File.exists?(@full_path)
      @is_multi_root = false
      @parent = FilesystemItem.new(@root, build_path(@path, '..'), kind: @kind)

      load_type
    end

    def is_directory? ; return @is_directory ; end

    def path ; return @path ||= @full_path || (@full_paths && "") ; end
    def url ; return @path.split('/').map { |p| URI::escape(p) }.join('/') ; end

    def is_root? ; return @is_root ; end
    def is_parent? ; return @is_parent || false ; end
    def exists? ; return @exists ; end
    def name ; return @name ; end
    def type ; return @type ; end
    def sub_type ; return @sub_type ; end
    def mime_type ; "#{type}/#{sub_type}" ; end
    def disposition
      case type
        when :image
          'inline'
        else
          'attachment'
      end
    end

    def modified_at(format = nil)
      return @modified_at if format.blank? || @modified_at.blank?
      return @modified_at.strftime(format)
    end
    def size ; return @size ; end

    def parent
      return nil if is_root?
      @parent ||= FilesystemItem.new(@root, File.join(@full_path, '..'), { root: @root, kind: @kind })
    end

    def root_item
      return @root_item unless @root_item.nil?
      @root_item = self

      @root_item = @root_item.parent while !@root_item.is_root?

      return @root_item
    end

    def children
      return nil unless is_directory?
      if @children.blank?
        if @is_multi_root
          if @is_root
            load_multi_root_children
          else
            load_multi_root_child_children
          end
        else
          load_single_root_children
        end

        sort_children
      end

      @children
    end

    def inspect ; return "[#{is_directory? ? 'D' : 'F'}] #{@full_path}" ; end

    def to_partial_path ; is_directory? ? 'directory' : 'file' ; end

    private

      def load_multi_root_children
        @children = @is_directory ? @full_paths.each_with_index.map do |r, index|
          Dir[File.join(Shellwords.escape(r), '*')].map do |f|
            FilesystemItem.new(@full_paths, f.gsub(/^#{r}/, "#{index}"), :index => index, kind: @kind)
          end
        end.flatten : []
      end

      def load_multi_root_child_children
        @children = @is_directory ? Dir[File.join(Shellwords.escape(@full_path), '*')].map do |f|
          FilesystemItem.new(@root, f.gsub(/^#{@root[@index]}/, "#{@index}"), :index => @index, kind: @kind)
        end : []
      end

      def load_single_root_children
        @children = @is_directory ? Dir[File.join(Shellwords.escape(@full_path), '*')].map do |f|
          FilesystemItem.new(@root, f.gsub(/^#{@root}\/?/, ''), kind: @kind)
        end : []
      end

      def sort_children
        @children.sort! do |a, b|
          if a.is_directory? && !b.is_directory?
            -1
          elsif !a.is_directory? && b.is_directory?
            1
          else
            a.name.downcase <=> b.name.downcase
          end
        end
      end

      def load_type
        @type = :directory if @is_directory

        unless @type
          if `file -I #{Shellwords.escape @full_path}`.strip =~ /^.*?:\s*(.*?);.*?$/
            @type, @sub_type = $1.split('/').map(&:to_sym)
          end
        end

        @type ||= :unknown
      end

      def build_path(*args)
        File.expand_path(File.join(*args)).gsub(/^#{Dir.pwd}\/?/, '')
      end
  end
end