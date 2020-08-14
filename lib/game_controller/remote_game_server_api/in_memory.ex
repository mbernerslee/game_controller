defmodule GameController.RemoteGameServerApi.InMemoryPoweredOn do
  def power_status, do: :running
  def power_on, do: raise("no powering on allowed when already powered on")
  def power_off, do: :powering_down
end

defmodule GameController.RemoteGameServerApi.InMemoryPoweredOff do
  def power_status, do: :powered_off
  def power_on, do: :starting_up
  def power_off, do: raise("no powering off allowed if already off")
end

defmodule GameController.RemoteGameServerApi.InMemoryStaringUp do
  def power_status, do: :starting_up
  def power_on, do: raise("you shouldn't be calling power_on if you're currently starting up")
  def power_off, do: raise("you shouldn't be calling power_off if you're currently starting up")
end

defmodule GameController.RemoteGameServerApi.InMemoryPoweringDown do
  def power_status, do: :powering_down
  def power_on, do: raise("you shouldn't be calling power_on if you're currently starting up")
  def power_off, do: raise("you shouldn't be calling power_off if you're currently starting up")
end
