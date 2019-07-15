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

    resources "/", GameController, only: [:new, :create]

    get "/join/", GameController, :join_new
    get "/join/:id", GameController, :join_new

    post "/join", GameController, :join_create

    get "/room/", GameController, :room

    get "/:id", GameController, :join_new
  end
end
