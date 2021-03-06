use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :game_controller, GameController.Repo,
  username: "postgres",
  password: "postgres",
  database: "game_controller_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :game_controller,
       :remote_game_server_api,
       GameController.RemoteGameServerApi.InMemoryPoweredOn

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :game_controller, GameControllerWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bcrypt_elixir, log_rounds: 0
