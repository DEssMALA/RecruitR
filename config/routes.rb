Rails.application.routes.draw do

  root 'positions#index'
  
  # Positions related routes
  resources :positions

  # Applicant related routes
  get '/applicants/new/:id', to: 'applicants#new'
  post '/applicants/create/:id', to: 'applicants#create'
  get '/applicants/:id', to: 'applicants#show', as: 'applicant'
  get '/applicants/:id/edit', to: 'applicants#edit'
  patch '/applicants/:id', to: 'applicants#update'
  get '/applicants', to: 'applicants#index'
  delete '/applicants/:id', to: 'applicants#destroy'
  get '/positions/:id/applicants', to: 'applicants#positions'
  get '/applicants/:id/recruiters', to: 'applicants#recruiters'
  post '/applicants/update_recruiter/:id', to: 'applicants#update_recruiter'
  post '/applicant_invite/:id', to: 'applicants#applicant_invite'

    # Positions related routes
    resources :recruiters

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
