Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/sms/send", to: "auth#send_sms"
      post "auth/login", to: "auth#login"
      post "auth/logout", to: "auth#logout"
      get "auth/me", to: "auth#me"

      get "users/profile", to: "users#profile"
      patch "users/profile", to: "users#update"

      resources :characters, only: [:index, :show, :create, :update] do
        collection do
          post :customize
        end
        member do
          post :care
          get :care_logs
        end
      end

      get "story/chapters", to: "story#chapters"
      post "story/episodes/:id/start", to: "story#start"
      post "story/episodes/:id/complete", to: "story#complete"

      get "shop/items", to: "shop#index"
      post "shop/purchase", to: "shop#purchase"

      get "inventory", to: "inventory#index"
      post "inventory/use", to: "inventory#use"

      get "daily/status", to: "daily#status"
      post "daily/check_in", to: "daily#check_in"

      get "achievements", to: "achievements#index"
      get "economy/wallet", to: "economy#wallet"

      get "learning/categories", to: "learning#categories"
      get "learning/skills", to: "learning#skills"
      get "learning/skills/:id", to: "learning#skill_detail"
      post "learning/courses/:id/start", to: "learning#start"
      post "learning/courses/:id/complete", to: "learning#complete"

      get "room", to: "rooms#show"
      patch "room", to: "rooms#update"
      get "room/shop", to: "rooms#shop"
      post "room/purchase", to: "rooms#purchase"
      post "room/place", to: "rooms#place"
      post "room/remove", to: "rooms#remove"

      # 虚拟地图探索
      post "map/enter", to: "map#enter"
      get "map/current", to: "map#current"
      post "map/move", to: "map#move"
      post "map/explore", to: "map#explore"
      get "map/events", to: "map#events"
      post "map/events/:id/start", to: "map#start_event"
      post "map/events/:id/complete", to: "map#complete_event"

      # 景区地图
      get "map/scenic", to: "map#scenic_list"
      post "map/scenic/enter", to: "map#scenic_enter"
      post "map/scenic/check_location", to: "map#check_location"
      post "map/scenic/check_beacon", to: "map#check_beacon"
      post "map/scenic/complete_task", to: "map#complete_task"

      # 客户端埋点上报
      post "tracking/events", to: "tracking#create"

      # 传感器触发（玩家端）
      post "sensors/trigger", to: "sensors#trigger"

      # 管理后台可配置 API（Header: X-Admin-Key）
      namespace :admin do
        get "config/overview", to: "config#overview"

        resources :game_maps, path: "maps" do
          member do
            post :upload_route_image
          end
        end
        resources :map_zones, path: "zones"
        resources :map_spawn_points, path: "spawn_points"
        resources :event_templates
        resources :sensor_triggers do
          collection do
            post :fire
          end
        end
        resources :learning_categories, only: [:index, :show, :update]

        resources :map_trigger_points, path: "trigger_points"
        resources :map_tasks, path: "tasks"
        get "player_activity", to: "player_activity#index"
        get "users/:user_id/activity", to: "player_activity#user_summary"
        get "users/:user_id/flow", to: "player_activity#user_flow"
      end
    end
  end

  get "health", to: proc { [200, {}, [{ status: "ok" }.to_json]] }

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
end
