defmodule GameController.RemoteGameServerApi.InMemory do
  def power_status, do: {:ok, :running}
end
