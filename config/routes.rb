Rails.application.routes.draw do
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  devise_for :users
  root 'welcome#index'

  resources :projects do
    delete '/assignments/:id/remove', to: 'projects#remove_user', as: 'remove_user'
    resources :bugs do
      member do
        post 'assign', as: 'assign'
        post 'update_status', as: 'status_update'
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
