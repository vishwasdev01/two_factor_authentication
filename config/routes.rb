Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#show"
  # resources :sessions, only: [:new, :create, :destroy]
  # post "/sign_up", to: 'users#sign_up'
  # post '/login', to: 'users#login'
  # post '/authenticate', to: 'users#two_factor_auth'
  # post '/enable2fa', to: 'users#enable_2fa'
  # post '/update_password', to: 'users#update_password'

  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  get 'logout'  => 'sessions#destroy'
  get 'otp' => 'sessions#otp'
  post 'add_otp' => 'sessions#add_otp'
  get 'enable_2fa' => 'sessions#enable_2fa'
  get 'disable_2fa' => 'sessions#disable_2fa'
  get 'qr' => 'sessions#qr'
  post 'verify_otp' => 'sessions#verify_otp', as: :verify_otp
  get 'otp_authenticate' => 'sessions#otp_authenticate', as: :otp_authenticate
  resources :users
end


