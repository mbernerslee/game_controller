defmodule GameController.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  alias GameController.RemoteServerStatus

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      GameController.Repo,
      # Start the Telemetry supervisor
      GameControllerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GameController.PubSub},
      # Start the Endpoint (http/https)
      GameControllerWeb.Endpoint,
      # Start a worker by calling: GameController.Worker.start_link(arg)
      # {GameController.Worker, arg}
      {RemoteServerStatus, RemoteServerStatus.initial_state()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GameController.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GameControllerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
