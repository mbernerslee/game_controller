defmodule GameController.RemoteServerStatus do
  use GenServer

  alias Phoenix.PubSub
  alias GameController.RemoteGameServerApi

  @name :remote_server_status
  def genserver_name, do: @name

  def name, do: "remote_server_status"

  # TODO rename to server status?
  # TODO add tests ffs!
  # TODO don't hit real api in dev and instead just update this genserver state?
  # TODO add a last_updated for the power, so that you can display it on the frontend
  def start_link(default) when is_map(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def initial_state do
    case RemoteGameServerApi.power_status() do
      {:ok, power_status} ->
        %{power: power_status}

      _ ->
        %{power: :unknown}
    end
  end

  def power_status do
    GenServer.call(@name, :get_power_status)
  end

  def power_on do
    GenServer.call(@name, :power_on)
  end

  def power_off do
    GenServer.call(@name, :power_off)
  end

  def refresh_power_status do
    GenServer.call(@name, :refresh_power_status)
  end

  @impl true
  def init(server_status) do
    {:ok, server_status}
  end

  @impl true
  def handle_call(:get_power_status, _from, server_status) do
    {:reply, server_status.power, server_status}
  end

  def handle_call(:power_on, _from, server_status) do
    server_status = update_power_status(&RemoteGameServerApi.power_on/0, server_status)
    IO.inspect("About to start check_until_powered_on")
    check_until_powered_on()
    {:reply, server_status.power, server_status}
  end

  def handle_call(:power_off, _from, server_status) do
    server_status = update_power_status(&RemoteGameServerApi.power_off/0, server_status)
    {:reply, server_status.power, server_status}
  end

  def handle_call(:refresh_power_status, _from, server_status) do
    server_status = update_power_status(&RemoteGameServerApi.power_status/0, server_status)
    {:reply, server_status.power, server_status}
  end

  @impl true
  def handle_cast(:check_until_powered_on, server_status) do
    case RemoteGameServerApi.power_status() do
      {:ok, :running} ->
        IO.inspect("Checking if its powered on - its running")
        server_status = update_power_status(fn -> {:ok, :running} end, server_status)
        {:noreply, server_status}

      _ ->
        IO.inspect("Checking if its powered on - its not")
        check_until_powered_on()
        {:noreply, server_status}
    end
  end

  defp check_until_powered_on do
    spawn_link(fn ->
      Process.sleep(2_000)
      GenServer.cast(@name, :check_until_powered_on)
    end)
  end

  defp update_power_status(new_power_status_fun, server_status) do
    {:ok, new_power_status} = new_power_status_fun.()

    PubSub.broadcast(GameController.PubSub, name(), {:power, new_power_status})
    Map.update!(server_status, :power, fn _ -> new_power_status end)
  end
end
