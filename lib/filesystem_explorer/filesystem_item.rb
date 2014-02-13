module FilesystemExplorer
  class FilesystemItem
    attr_reader :root
    attr_reader :full_path

    def initialize(full_path, options = {})
      options[:root] ||= '/'

      @full_path = File.expand_path(File.join(options[:root], File.join('/', full_path.gsub(/^#{options[:root]}/, ''))))
      @root = File.expand_path(options[:root])
    end

    def is_directory?
      @is_directory = File.directory?(@full_path) if @is_directory.blank?
      @is_directory
    end

    def path ; return @full_path.gsub(/^#{@root}/, '').gsub(/^\//, '') ; end
    def is_root? ; return @full_path == @root ; end
    def is_parent? ; return @is_parent || false ; end
    def exists? ; return File.exists?(@full_path) ; end

    def name ; @name ||= File.basename(path) ; end
    def modified_at ; @modified_at ||= File.mtime(@full_path) ; end
    def size ; @size ||= File.size(@full_path) ; end

    def parent
      return nil if is_root?
      @parent ||= FilesystemItem.new(File.join(@full_path, '..'), { root: @root })
    end

    def children
      return nil unless is_directory?
      if @children.blank?
        @children = Dir[File.join(Shellwords.escape(@full_path), '*')].map { |f| FilesystemItem.new(f, { root: @root }) }
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

      @children
    end

    def inspect ; return "[#{is_directory? ? 'D' : 'F'}] #{@full_path}" ; end

    def to_partial_path ; is_directory? ? 'directory' : 'file' ; end
  end
end