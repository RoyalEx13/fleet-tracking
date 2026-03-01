defmodule FleetTrackingWeb.Router do
  use FleetTrackingWeb, :router
  use AshAuthentication.Phoenix.Router
  import AshAuthentication.Plug.Helpers
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FleetTrackingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug AshAuthentication.Strategy.ApiKey.Plug,
      resource: FleetTracking.Accounts.User,
      # if you want to require an api key to be supplied, set `required?` to true
      required?: false

    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/", FleetTrackingWeb do
    pipe_through [:browser]
    get "/", HomeController, :index
    auth_routes AuthController, FleetTracking.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{FleetTrackingWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    FleetTrackingWeb.AuthOverrides,
                    Elixir.AshAuthentication.Phoenix.Overrides.Default
                  ]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [
                  FleetTrackingWeb.AuthOverrides,
                  Elixir.AshAuthentication.Phoenix.Overrides.Default
                ]

    # Remove this if you do not use the confirmation strategy
    confirm_route FleetTracking.Accounts.User, :confirm_new_user,
      auth_routes_prefix: "/auth",
      overrides: [
        FleetTrackingWeb.AuthOverrides,
        Elixir.AshAuthentication.Phoenix.Overrides.Default
      ]

    # Remove this if you do not use the magic link strategy.
    magic_sign_in_route(FleetTracking.Accounts.User, :magic_link,
      auth_routes_prefix: "/auth",
      overrides: [
        FleetTrackingWeb.AuthOverrides,
        Elixir.AshAuthentication.Phoenix.Overrides.Default
      ]
    )
  end

  scope "/", FleetTrackingWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {FleetTrackingWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {FleetTrackingWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {FleetTrackingWeb.LiveUserAuth, :live_no_user}
    end
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/json/open_api",
      default_model_expand_depth: 4

    forward "/", FleetTrackingWeb.AshJsonApiRouter
  end

  scope "/api", FleetTrackingWeb do
    pipe_through :api
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:fleet_tracking, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FleetTrackingWeb.Telemetry
    end
  end

  if Application.compile_env(:fleet_tracking, :dev_routes) do
    import AshAdmin.Router

    scope "/" do
      pipe_through :browser
      ash_admin "/admin"
    end
  end
end
