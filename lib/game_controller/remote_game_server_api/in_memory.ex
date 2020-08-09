defmodule GameController.RemoteGameServerApi.InMemory do
  def power_status, do: {:ok, :running}
  def power_on, do: {:ok, :already_on}
  def power_off, do: {:ok, :powering_down}
end
