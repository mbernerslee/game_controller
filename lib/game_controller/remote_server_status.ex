defmodule GameController.RemoteServerStatus do
  use GenServer

  alias GameController.RemoteGameServerApi

  @keys [:power]
  @name :remote_server_status

  # TODO rename to remote server state?
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

  def update(key, value) do
    GenServer.cast(@name, {:update, key, value})
  end

  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  @impl true
  def init(server_status) do
    {:ok, server_status}
  end

  @impl true
  def handle_call({:get, key}, _from, server_status) do
    {:reply, server_status[key], server_status}
  end

  @impl true
  def handle_cast({:update, key, value}, server_status) when key in @keys do
    {:noreply, Map.update!(server_status, key, fn _ -> value end)}
  end

  def handle_cast({:update, _key, _value}, server_status) do
    {:noreply, server_status}
  end
end
