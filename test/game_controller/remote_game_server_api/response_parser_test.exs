defmodule GameController.RemoteGameServerApi.ResponseParserTest do
  use ExUnit.Case, async: true
  alias GameController.RemoteGameServerApi.ResponseParser

  describe "power_status/1" do
    test "when it is running" do
      api_response =
        {:ok,
         %{
           "InstanceStatuses" => [
             %{"InstanceState" => %{"Code" => 16, "Name" => "running"}}
           ]
         }}

      assert ResponseParser.power_status(api_response) == {:ok, :running}
    end

    test "when it's off" do
      api_response = {:ok, %{"InstanceStatuses" => []}}
      assert ResponseParser.power_status(api_response) == {:ok, :powered_off}
    end

    test "unknown if two instances are returned" do
      api_response =
        {:ok,
         %{
           "InstanceStatuses" => [
             %{"InstanceState" => %{"Code" => 16, "Name" => "running"}},
             %{"InstanceState" => %{"Code" => 16, "Name" => "running"}}
           ]
         }}

      assert ResponseParser.power_status(api_response) == {:ok, :unknown}
    end

    test "unknown if given total jank" do
      api_response = {:ok, %{"totalJank" => "balls"}}
      assert ResponseParser.power_status(api_response) == {:ok, :unknown}
    end

    test "when its an unrecognised instatance state name, its OK unknown" do
      api_response =
        {:ok,
         %{
           "InstanceStatuses" => [
             %{"InstanceState" => %{"Code" => 15, "Name" => "wtf is this name?"}}
           ]
         }}

      assert ResponseParser.power_status(api_response) == {:ok, :unknown}
    end
  end

  describe "power_on/1" do
    test "when its already on" do
      api_response =
        {:ok,
         %{
           "StartingInstances" => [
             %{
               "CurrentState" => %{"Name" => "running"},
               "PreviousState" => %{"Name" => "running"}
             }
           ]
         }}

      assert ResponseParser.power_on(api_response) == {:ok, :running}
    end

    test "when its starting up" do
      api_response =
        {:ok,
         %{
           "StartingInstances" => [
             %{
               "CurrentState" => %{"Name" => "pending"},
               "PreviousState" => %{"Name" => "stopped"}
             }
           ]
         }}

      assert ResponseParser.power_on(api_response) == {:ok, :starting_up}
    end

    test "unknown if given unparsable jank" do
      api_response = {:ok, %{"total_balls" => "jank"}}

      assert ResponseParser.power_on(api_response) == {:ok, :unknown}
    end
  end

  describe "power_off/0" do
    test "when its already off" do
      response =
        {:ok,
         %{
           "StoppingInstances" => [
             %{
               "CurrentState" => %{"Name" => "stopped"},
               "PreviousState" => %{"Name" => "stopped"}
             }
           ]
         }}

      assert ResponseParser.power_off(response) == {:ok, :already_stopped}
    end

    test "when its stopping now" do
      response =
        {:ok,
         %{
           "StoppingInstances" => [
             %{
               "CurrentState" => %{"Name" => "stopped"},
               "PreviousState" => %{"Name" => "running"}
             }
           ]
         }}

      assert ResponseParser.power_off(response) == {:ok, :powering_down}
    end
  end
end
