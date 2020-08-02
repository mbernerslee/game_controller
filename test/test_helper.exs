ExUnit.configure(exclude: [:remote_game_server_real_api])
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GameController.Repo, :manual)
