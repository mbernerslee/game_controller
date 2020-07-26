defmodule GameControllerWeb.Router do
  use GameControllerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :logged_in do
    plug GameControllerWeb.Plugs.LoggedIn
  end

  pipeline :logged_out do
    plug GameControllerWeb.Plugs.LoggedOut
  end

  scope "/", GameControllerWeb do
    pipe_through :browser

    scope "/" do
      pipe_through :logged_out

      scope "/login" do
        get "/", LoginController, :show
        post "/", LoginController, :create
      end
    end

    scope "/" do
      pipe_through :logged_in

      get "/", MainPageController, :show

      import Phoenix.LiveDashboard.Router
      live_dashboard "/dashboard", metrics: GameControllerWeb.Telemetry

      scope "/main-page" do
        get "/", MainPageController, :show
      end
    end
  end
end
