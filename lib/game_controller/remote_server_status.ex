defmodule GameController.RemoteServerStatus do
  use GenServer
  require Logger

  alias Phoenix.PubSub
  alias GameController.RemoteGameServerApi

  @name :remote_server_status
  def genserver_name, do: @name

  def pub_sub_name, do: "remote_server_status"

  def start_link([]) do
    GenServer.start_link(__MODULE__, initial_state())
  end

  def start_link(default, opts \\ []) when is_map(default) do
    opts =
      if Keyword.get(opts, :no_name, false) do
        []
      else
        [name: @name]
      end

    GenServer.start_link(__MODULE__, default, opts)
  end

  def initial_state do
    server_status = %{power: RemoteGameServerApi.power_status(), seconds_since_power_checked: 0}
    debug_log(server_status, "Initialising remote server status")
    server_status
  end

  def power_status(pid \\ @name) do
    GenServer.call(pid, :get_power_status)
  end

  def power_on(pid \\ @name) do
    GenServer.call(pid, :power_on)
  end

  def power_off(pid \\ @name) do
    GenServer.call(pid, :power_off)
  end

  def refresh_power_status(pid \\ @name) do
    GenServer.call(pid, :refresh_power_status)
  end

  def seconds_since_power_checked(pid \\ @name) do
    GenServer.call(pid, :seconds_since_power_checked)
  end

  defp increment_timer_in_one_second do
    pid = self()

    spawn_link(fn ->
      Process.sleep(1_000)
      GenServer.cast(pid, :increment_timer)
    end)
  end

  @impl true
  def init(server_status) do
    increment_timer_in_one_second()
    {:ok, server_status}
  end

  @impl true
  def handle_call(:seconds_since_power_checked, _from, server_status) do
    debug_log(
      server_status,
      "seconds_since_power_checked = #{server_status.seconds_since_power_checked}"
    )

    {:reply, server_status.seconds_since_power_checked, server_status}
  end

  def handle_call(:get_power_status, _from, server_status) do
    debug_log(server_status, "returning in memory power status")
    {:reply, server_status.power, server_status}
  end

  @transitional_power_states [:powering_on, :powering_off]

  def handle_call(:power_on, _from, server_status) do
    if server_status.power in [:running | @transitional_power_states] do
      {:reply, server_status.power, server_status}
    else
      spawn_link(fn -> RemoteGameServerApi.power_on() end)
      server_status = broadcast_and_update_power_status(:powering_on, server_status)
      check_until_powered_on()
      debug_log(server_status)
      {:reply, server_status.power, server_status}
    end
  end

  def handle_call(:power_off, _from, server_status) do
    if server_status.power in [:powered_off | @transitional_power_states] do
      {:reply, server_status.power, server_status}
    else
      spawn_link(fn -> RemoteGameServerApi.power_off() end)
      check_until_powered_down()
      server_status = broadcast_and_update_power_status(:powering_off, server_status)
      debug_log(server_status)
      {:reply, server_status.power, server_status}
    end
  end

  def handle_call(:refresh_power_status, _from, server_status) do
    if server_status.power in @transitional_power_states do
      {:reply, server_status.power, server_status}
    else
      pid = self()

      spawn_link(fn ->
        GenServer.cast(pid, {:fetched_power_status, RemoteGameServerApi.power_status()})
      end)

      server_status =
        broadcast_and_update_power_status(:fetching_power_status, server_status,
          reset_timer: false
        )

      debug_log(server_status)
      {:reply, server_status.power, server_status}
    end
  end

  defp debug_log(%{power: power_status}) do
    Logger.debug("#{__MODULE__} - '#{power_status}'")
  end

  defp debug_log(%{power: power_status}, msg) do
    Logger.debug("#{__MODULE__} - '#{power_status}' - #{msg}")
  end

  defp check_until_powered_down do
    pid = self()

    spawn_link(fn ->
      Process.sleep(2_000)
      GenServer.cast(pid, :check_until_powered_down)
    end)
  end

  defp check_until_powered_on do
    pid = self()

    spawn_link(fn ->
      Process.sleep(2_000)
      GenServer.cast(pid, :check_until_powered_on)
    end)
  end

  defp broadcast_and_update_power_status(new_power_status, server_status, opts \\ []) do
    PubSub.broadcast(GameController.PubSub, pub_sub_name(), {:power, new_power_status})
    server_status = %{server_status | power: new_power_status}

    if Keyword.get(opts, :reset_timer, true) do
      broadcast_and_update_seconds_since_power_checked(0, server_status)
    else
      server_status
    end
  end

  @impl true
  def handle_cast(:check_until_powered_on, server_status) do
    case RemoteGameServerApi.power_status() do
      :running ->
        server_status = broadcast_and_update_power_status(:running, server_status)
        debug_log(server_status, "checking until powered on finished")
        {:noreply, server_status}

      _ ->
        GenServer.cast(self(), :reset_timer)
        debug_log(server_status, "still checking until powered on...")
        check_until_powered_on()
        {:noreply, server_status}
    end
  end

  def handle_cast(:check_until_powered_down, server_status) do
    case RemoteGameServerApi.power_status() do
      :powered_off ->
        server_status = broadcast_and_update_power_status(:powered_off, server_status)
        debug_log(server_status, "checking until powered down finished")
        {:noreply, server_status}

      _ ->
        GenServer.cast(self(), :reset_timer)
        debug_log(server_status, "still checking until powered down...")
        check_until_powered_down()
        {:noreply, server_status}
    end
  end

  def handle_cast({:fetched_power_status, power_status}, server_status) do
    server_status = broadcast_and_update_power_status(power_status, server_status)
    debug_log(server_status, "fetched power status")
    {:noreply, server_status}
  end

  def handle_cast(:increment_timer, server_status) do
    server_status =
      server_status.seconds_since_power_checked
      |> Kernel.+(1)
      |> broadcast_and_update_seconds_since_power_checked(server_status)

    increment_timer_in_one_second()
    {:noreply, server_status}
  end

  def handle_cast(:reset_timer, server_status) do
    server_status = broadcast_and_update_seconds_since_power_checked(0, server_status)
    {:noreply, server_status}
  end

  defp broadcast_and_update_seconds_since_power_checked(seconds, server_status) do
    broadcast = {:seconds_since_power_checked, seconds}
    PubSub.broadcast(GameController.PubSub, pub_sub_name(), broadcast)
    %{server_status | seconds_since_power_checked: seconds}
  end
end
