defmodule NekoAuthWeb.Router do
  use NekoAuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NekoAuthWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug NekoAuth.Context
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Jason
  end

  scope "/api/graphql" do
    pipe_through :graphql

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: NekoAuthWeb.Schema

    forward "/", Absinthe.Plug,
      schema: NekoAuthWeb.Schema
  end




  pipeline :authorize do
    plug  NekoAuthWeb.Plugs.IsAuthorizedPlug
  end

  scope "/", NekoAuthWeb do
    pipe_through :browser
    get "/", PageController, :home
    get "/login", PageController, :login
    get "/register", PageController, :register
  end

  scope "/portal", NekoAuthWeb do
    pipe_through [:browser, :authorize]
    get "/", PageController, :home
    get "/services", PageController, :home
  end

  scope "/.well-known", NekoAuthWeb do
    pipe_through :api
    get "jwks.json", OpenidcController, :jwks
    get "openid-configuration", OpenidcController, :config
  end

  scope "/api/v1", NekoAuthWeb do
    pipe_through :api
    get "/oauth/authorize", OAuthController, :authorize
    post "/oauth/token", OAuthController, :token
    get "/oauth/user", UserController, :user

    get "/portal/callback", PortalController, :callback

    post "/register", UserController, :register
    post "/login", UserController, :login
    get "/avatars/:user_name/:descriminator", UserController, :avatar
  end



  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:neko_auth, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    #scope "/dev" do
    #  pipe_through :browser
    #
    #  live_dashboard "/dashboard", metrics: DemoWeb.Telemetry
    #  forward "/mailbox", Plug.Swoosh.MailboxPreview
    #end
  end
end
