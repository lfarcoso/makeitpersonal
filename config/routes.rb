Makeitpersonal::Application.routes.draw do
  devise_for :users

  get "/lyrics", :to => "lyrics#lyrics", :as => "fetch_lyrics"
  get "/disclaimer", to: "pages#disclaimer"
  get "/contact", to: "pages#contact"
  get "/credits", to: "pages#credits"

  resources :songs, :except => [:index, :show]

  # user
  get "/signup", :to => "pages#sign_up", :as => "sign_up"
  get "/account", :to => "users#show", :as => "account"
  get "/account/settings", :to => "users#edit", :as => "settings"

  root :to => "pages#index"

  # songs
  get "/:username/:id", :to => "songs#show", :as => "user_song"
  get "/:username", :to => "songs#index", :as => "user"

end
