Rails.application.routes.draw do

  devise_for :users
  root to: 'positions#index'
  
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

  # Google calendar routes
  get '/redirect', to: 'calendar_api#redirect', as: 'redirect'
  get '/callback', to: 'calendar_api#callback', as: 'callback'
  get '/calendars', to: 'calendar_api#calendars', as: 'calendars'
  get '/events/:calendar_id', to: 'calendar_api#events', as: 'events', calendar_id: /[^\/]+/
  post '/events/:calendar_id', to: 'calendar_api#new_event', as: 'new_event', calendar_id: /[^\/]+/
  get '/new_interview/:id', to: 'calendar_api#new_interview', as: 'new_interview'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
