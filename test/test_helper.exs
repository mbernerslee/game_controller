ExUnit.configure(exclude: [:slow_tests])
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GameController.Repo, :manual)
