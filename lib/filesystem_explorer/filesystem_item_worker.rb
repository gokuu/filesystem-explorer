module FilesystemExplorer
  class FilesystemItemWorker
    include Sidekiq::Worker

    sidekiq_options unique: :until_and_while_executing

    def perform(root, relative_path, thumbnail_size, force = false)
      item = FilesystemItem.new root, relative_path
      item.generate_photo_thumbnail! thumbnail_size, false
    end
  end
end