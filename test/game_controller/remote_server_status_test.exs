defmodule GameController.RemoteServerStatusTest do
  use ExUnit.Case, async: true
  alias GenServer
  alias GameController.RemoteServerStatus

  alias GameController.RemoteGameServerApi.{
    InMemoryPoweredOn,
    InMemoryPoweredOff,
    InMemoryPoweringOn,
    InMemoryPoweringOff
  }

  @moduletag :slow_tests

  setup do
    on_exit(fn ->
      Application.put_env(:game_controller, :remote_game_server_api, InMemoryPoweredOn)
    end)
  end

  test "its initial state" do
    Application.put_env(:game_controller, :remote_game_server_api, InMemoryPoweredOn)

    assert RemoteServerStatus.initial_state() == %{
             power: :running,
             seconds_since_power_checked: 0
           }
  end

  describe "power_status/0" do
    test "when it's on" do
      pid = start_remote_server_status(InMemoryPoweredOn)
      assert RemoteServerStatus.power_status(pid) == :running

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refresh_power_status(pid) == :fetching_power_status
      assert_receive {:trace, ^pid, :receive, {_, _, :refresh_power_status}}
      assert_receive {:trace, ^pid, :receive, {_, {:fetched_power_status, :running}}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when it's off" do
      pid = start_remote_server_status(InMemoryPoweredOff)
      assert RemoteServerStatus.power_status(pid) == :powered_off

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refresh_power_status(pid) == :fetching_power_status
      assert_receive {:trace, ^pid, :receive, {_, _, :refresh_power_status}}
      assert_receive {:trace, ^pid, :receive, {_, {:fetched_power_status, :powered_off}}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when it's powering_on" do
      pid = start_remote_server_status(InMemoryPoweringOn)
      assert RemoteServerStatus.power_status(pid) == :powering_on

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refresh_power_status(pid) == :powering_on
      assert_receive {:trace, ^pid, :receive, {_, _, :refresh_power_status}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when it's powering off, refresh_power_status does nothing" do
      pid = start_remote_server_status(InMemoryPoweringOff)
      assert RemoteServerStatus.power_status(pid) == :powering_off

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refresh_power_status(pid) == :powering_off
      assert_receive {:trace, ^pid, :receive, {_, _, :refresh_power_status}}
      refute_receive {:trace, ^pid, :receive, _}
    end
  end

  describe "power_on/0" do
    test "when already on" do
      pid = start_remote_server_status(InMemoryPoweredOn)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_on(pid) == :running
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when off" do
      pid = start_remote_server_status(InMemoryPoweredOff)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_on(pid) == :powering_on
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when starting up" do
      pid = start_remote_server_status(InMemoryPoweringOn)
      assert RemoteServerStatus.power_status(pid) == :powering_on

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_on(pid) == :powering_on
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when powering down" do
      pid = start_remote_server_status(InMemoryPoweringOff)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_on(pid) == :powering_off
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end
  end

  describe "power_off/0" do
    test "when on" do
      pid = start_remote_server_status(InMemoryPoweredOn)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powering_off
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when already off" do
      pid = start_remote_server_status(InMemoryPoweredOff)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powered_off
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when starting up" do
      pid = start_remote_server_status(InMemoryPoweringOn)
      assert RemoteServerStatus.power_status(pid) == :powering_on

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powering_on
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when powering off" do
      pid = start_remote_server_status(InMemoryPoweringOff)
      assert RemoteServerStatus.power_status(pid) == :powering_off

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powering_off
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end
  end

  defp start_remote_server_status(api_module) do
    Application.put_env(:game_controller, :remote_game_server_api, api_module)
    start_supervised!(RemoteServerStatus)
  end
end
