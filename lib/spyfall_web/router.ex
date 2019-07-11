defmodule SpyfallWeb.Router do
  use SpyfallWeb, :router

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

  scope "/", SpyfallWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/game", GameController, only: [:new, :create]
  end

end
