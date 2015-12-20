module FilesystemExplorer
  class DragonflyDataStore

    # Store the data AND meta, and return a unique string uid
    def write(content, opts={})
      SecureRandom.uuid
    end

    # Retrieve the data and meta as a 2-item array
    def read(uid)
      File.new uid
    end

    def destroy(uid)
    end

  end
end