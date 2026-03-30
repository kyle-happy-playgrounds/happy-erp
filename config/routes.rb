Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  #
  #  devise_for :users
#    devise_for :users, path_names: {
#                sign_up: '' #Stop Sign Up
#        }
    devise_for :users, skip: [:registrations]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

        #root to: "happy_orders#index"
        root to: "happy_customer_companies#index"

        resources :happy_customer_companies

        resources :happy_customers do
          resources :happy_quotes, :happy_orders
        end


        resources :happy_quotes do
          collection do
              get  :start
              post :start_create
          end

          resources :happy_quote_lines
          patch :move
          get 'po'
          get 'pwfreight'
          get 'pocreate'
          get 'poview'
          get 'copy'
          get 'createsub'
          get 'sortlines'
          patch :set_status, on: :member
        end

        resources :happy_pos do
          resources :happy_po_lines
          get 'finalize'
          get 'poprint'
        end

        #resources :happy_orders do
          #resources :happy_order_lines
        #end

        resources :happy_projects do
          resources :happy_project_tasks
              get 'loadprocess'
          match :add, via: [:get, :post]
        end

        resources :happy_standard_tasks do
           resources :happy_standard_activities
        end

        resources :happy_standard_processes

        resources :happy_reminders do
          collection do
            get :edit_multiple
            put :update_multiple
          end
        end

        resources :happy_project_members
        resources :happy_project_teams

        #resources :happy_standard_tasks
        #resources :happy_standard_processes
        #resources :happy_standard_activities

        resources :happy_vendors

        resources :happy_install_sites do
          get 'customer_select'
        end

        get '/happy_products/productinfo', action: :productinfo,  controller: 'happy_products'
        resources :happy_products

        resources :happy_categories

        # added for jwt 11/16/2025
        namespace :api do
          namespace :v1 do
            devise_for :users,
            path: '',
            path_names: { sign_in: 'login', sign_out: 'logout' },
            controllers: { sessions: 'api/v1/sessions' }

            # KPIs for the Overview tab
            get "kpis/overview", to: "kpis#overview"
            get "kpis/team",     to: "team_kpis#index"

            # Quotes for the Pipeline tab (and detail view later)
            resources :quotes, only: [:index, :show]

          end
        end


end
