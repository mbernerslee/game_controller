defmodule GameController.Repo do
  use Ecto.Repo,
    otp_app: :game_controller,
    adapter: Ecto.Adapters.Postgres
end
