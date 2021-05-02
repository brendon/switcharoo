Admin::Engine.routes.draw do
  resources :entities

  root :to => 'entities#index'
end
