defmodule GameController.RemoteGameServerApi do
  def power_status, do: remote_game_server_api_module().power_status
  def power_on, do: remote_game_server_api_module().power_on
  def power_off, do: remote_game_server_api_module().power_off

  defp remote_game_server_api_module do
    Application.get_env(:game_controller, :remote_game_server_api)
  end
end
