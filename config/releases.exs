import Config

config :logger, level: String.to_atom(System.get_env("LOGGER_LEVER", "info"))

config :spyfall, SpyfallWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT", "4000"))],
  url: [host: System.fetch_env!("DOMAIN_NAME"), scheme: "https", port: 443],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :libcluster,
  topologies: [
    spyfall: [
      strategy: Elixir.Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: System.get_env("SERVICE_NAME", "spyfall"),
        application_name: "spyfall",
        polling_interval: 5_000
      ]
    ]
  ]
