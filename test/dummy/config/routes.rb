Rails.application.routes.draw do

  mount FilesystemExplorer::Engine => "/filesystem_explorer"
end
