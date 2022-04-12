Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: "top10#index"

  post "/api/getTop10ByCity", "api#getTop10ByCity"
end
