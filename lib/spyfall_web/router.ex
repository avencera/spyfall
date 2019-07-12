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


    get "/game/join/", GameController, :join_new
    get "/game/join/:id", GameController, :join_new
    post "/game/join", GameController, :join_create

    get "/game/:id", GameController, :room
  end

end
