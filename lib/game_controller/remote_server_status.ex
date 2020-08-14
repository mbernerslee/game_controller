defmodule GameController.RemoteServerStatus do
  use GenServer

  alias Phoenix.PubSub
  alias GameController.RemoteGameServerApi

  @name :remote_server_status
  def genserver_name, do: @name

  def pub_sub_name, do: "remote_server_status"

  # TODO add tests ffs!
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

  def refetch_power_status do
    GenServer.call(@name, :refetch_power_status)
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
    spawn_link(fn -> RemoteGameServerApi.power_on() end)
    check_until_powered_on()
    server_status = broadcast_and_update_power_status(:starting_up, server_status)
    {:reply, server_status.power, server_status}
  end

  def handle_call(:power_off, _from, server_status) do
    spawn_link(fn -> RemoteGameServerApi.power_off() end)
    check_until_powered_down()
    server_status = broadcast_and_update_power_status(:powering_down, server_status)
    {:reply, server_status.power, server_status}
  end

  def handle_call(:refetch_power_status, _from, server_status) do
    spawn_link(fn ->
      power_status =
        case RemoteGameServerApi.power_status() do
          {:ok, power_status} ->
            power_status

          _ ->
            :unknown
        end

      GenServer.cast(@name, {:fetched_power_status, power_status})
    end)

    server_status = broadcast_and_update_power_status(:fetching_power_status, server_status)
    {:reply, server_status.power, server_status}
  end

  defp check_until_powered_down do
    spawn_link(fn ->
      Process.sleep(2_000)
      GenServer.cast(@name, :check_until_powered_down)
    end)
  end

  defp check_until_powered_on do
    spawn_link(fn ->
      Process.sleep(2_000)
      GenServer.cast(@name, :check_until_powered_on)
    end)
  end

  defp broadcast_and_update_power_status(new_power_status, server_status) do
    PubSub.broadcast(GameController.PubSub, pub_sub_name(), {:power, new_power_status})
    %{server_status | power: new_power_status}
  end

  @impl true
  def handle_cast(:check_until_powered_on, server_status) do
    case RemoteGameServerApi.power_status() do
      {:ok, :running} ->
        {:noreply, broadcast_and_update_power_status(:running, server_status)}

      _ ->
        check_until_powered_on()
        {:noreply, server_status}
    end
  end

  def handle_cast(:check_until_powered_down, server_status) do
    case RemoteGameServerApi.power_status() do
      {:ok, :powered_off} ->
        {:noreply, broadcast_and_update_power_status(:powered_off, server_status)}

      _ ->
        check_until_powered_down()
        {:noreply, server_status}
    end
  end

  def handle_cast({:fetched_power_status, power_status}, server_status) do
    {:noreply, broadcast_and_update_power_status(power_status, server_status)}
  end
end
