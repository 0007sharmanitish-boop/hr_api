Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "analytics/country_salary_statistics", to: "analytics#country_salary_statistics"
      get "analytics/job_title_average_salary", to: "analytics#job_title_average_salary"

      resources :employees
      resources :public_resources, only: [] do
        get :allowed_resource_list, on: :collection
      end
    end
  end
end
