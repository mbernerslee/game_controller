defmodule GameController.RemoteServerStatusTest do
  use ExUnit.Case, async: true
  alias GenServer
  alias GameController.RemoteServerStatus

  alias GameController.RemoteGameServerApi.{
    InMemoryPoweredOn,
    InMemoryPoweredOff,
    InMemoryStaringUp,
    InMemoryPoweringDown
  }

  @moduletag :slow_tests

  setup do
    on_exit(fn ->
      Application.put_env(:game_controller, :remote_game_server_api, InMemoryPoweredOn)
    end)
  end

  # TODO consistent naming of atoms. power_on, starting_up (instead of powering_up) etc etc
  describe "power_status/0" do
    test "when it's on" do
      pid = start_remote_server_status(InMemoryPoweredOn)
      assert RemoteServerStatus.power_status(pid) == :running

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refetch_power_status(pid) == :fetching_power_status
      assert_receive {:trace, ^pid, :receive, {_, _, :refetch_power_status}}
      assert_receive {:trace, ^pid, :receive, {_, {:fetched_power_status, :running}}}
    end

    test "when it's off" do
      pid = start_remote_server_status(InMemoryPoweredOff)
      assert RemoteServerStatus.power_status(pid) == :powered_off

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refetch_power_status(pid) == :fetching_power_status
      assert_receive {:trace, ^pid, :receive, {_, _, :refetch_power_status}}
      assert_receive {:trace, ^pid, :receive, {_, {:fetched_power_status, :powered_off}}}
    end

    test "when it's starting_up" do
      pid = start_remote_server_status(InMemoryStaringUp)
      assert RemoteServerStatus.power_status(pid) == :starting_up

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refetch_power_status(pid) == :starting_up
      assert_receive {:trace, ^pid, :receive, {_, _, :refetch_power_status}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when it's powering off, refetch_power_status does nothing" do
      pid = start_remote_server_status(InMemoryPoweringDown)
      assert RemoteServerStatus.power_status(pid) == :powering_down

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.refetch_power_status(pid) == :powering_down
      assert_receive {:trace, ^pid, :receive, {_, _, :refetch_power_status}}
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
      assert RemoteServerStatus.power_on(pid) == :starting_up
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when starting up" do
      pid = start_remote_server_status(InMemoryStaringUp)
      assert RemoteServerStatus.power_status(pid) == :starting_up

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_on(pid) == :starting_up
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when powering down" do
      pid = start_remote_server_status(InMemoryPoweringDown)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_on(pid) == :powering_down
      assert_receive {:trace, ^pid, :receive, {_, _, :power_on}}
      refute_receive {:trace, ^pid, :receive, _}
    end
  end

  describe "power_off/0" do
    test "when on" do
      pid = start_remote_server_status(InMemoryPoweredOn)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powering_down
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
    end

    test "when already off" do
      pid = start_remote_server_status(InMemoryPoweredOff)
      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powered_off
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when starting up" do
      pid = start_remote_server_status(InMemoryStaringUp)
      assert RemoteServerStatus.power_status(pid) == :starting_up

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :starting_up
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end

    test "when powering off" do
      pid = start_remote_server_status(InMemoryPoweringDown)
      assert RemoteServerStatus.power_status(pid) == :powering_down

      :erlang.trace(pid, true, [:receive])
      assert RemoteServerStatus.power_off(pid) == :powering_down
      assert_receive {:trace, ^pid, :receive, {_, _, :power_off}}
      refute_receive {:trace, ^pid, :receive, _}
    end
  end

  defp start_remote_server_status(api_module) do
    Application.put_env(:game_controller, :remote_game_server_api, api_module)
    start_supervised!(RemoteServerStatus)
  end
end
