# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :game_controller,
  ecto_repos: [GameController.Repo]

# Configures the endpoint
config :game_controller, GameControllerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "McFrw+tbF7azP/xeUMIVTod2JDuY2oor8KGiNedBSB+pG0+lcGsvapZaWEU9IAKX",
  render_errors: [view: GameControllerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: GameController.PubSub,
  live_view: [signing_salt: "E3JHPazV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
