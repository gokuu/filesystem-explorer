FilesystemExplorer::Engine.routes.draw do
  get '*path/download'  => 'application#download', as: :file_download
  get '*path'  => 'application#index'
  root to: 'application#index'
end