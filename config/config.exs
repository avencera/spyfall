use Mix.Config

# Configures the endpoint
config :spyfall, SpyfallWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "8KAXCTO+iMII+Og3D87RGiBWSfn54UF5O+z8gctCGq+5TGMIbmB7c0Ug8Ij0VISH",
  render_errors: [view: SpyfallWeb.ErrorView, accepts: ~w(html json)],
  live_view: [
    signing_salt: "b4752y577Gfvn1utx2RS+X1YFaFEKJtz"
  ],
  pubsub: [name: Spyfall.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
