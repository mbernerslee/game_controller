defmodule GameController.RemoteGameServerApi.ResponseParserTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias GameController.RemoteGameServerApi.ResponseParser

  describe "power_status/1" do
    test "when it is running" do
      api_response =
        {:ok,
         %{
           "InstanceStatuses" => [
             %{"InstanceState" => %{"Name" => "running"}}
           ]
         }}

      assert ResponseParser.power_status(api_response) == :running
    end

    test "when it's off" do
      api_response = {:ok, %{"InstanceStatuses" => []}}
      assert ResponseParser.power_status(api_response) == :powered_off
    end

    test "unknown if two instances are returned" do
      response = %{
        "InstanceStatuses" => [
          %{"InstanceState" => %{"Name" => "running"}},
          %{"InstanceState" => %{"Name" => "running"}}
        ]
      }

      api_response = {:ok, response}

      logging =
        capture_log(fn -> assert ResponseParser.power_status(api_response) == :unknown end)

      assert logging =~ "Failed to parse AWS API response to :power_status request."
      assert logging =~ "Got response: #{inspect(response)}"
    end

    test "unknown if given total jank" do
      api_response = {:ok, %{"totalJank" => "balls"}}

      logging =
        capture_log(fn -> assert ResponseParser.power_status(api_response) == :unknown end)

      assert logging =~ "Failed to parse AWS API response to :power_status request."
      assert logging =~ "Got response: #{inspect(%{"totalJank" => "balls"})}"
    end

    test "when its an unrecognised instatance state name, its OK unknown" do
      response = %{
        "InstanceStatuses" => [
          %{"InstanceState" => %{"Code" => 15, "Name" => "wtf is this name?"}}
        ]
      }

      api_response = {:ok, response}

      logging =
        capture_log(fn -> assert ResponseParser.power_status(api_response) == :unknown end)

      assert logging =~ "Failed to parse AWS API response to :power_status request."
      assert logging =~ "Got response: #{inspect(response)}"
    end

    test "returns unknown and loggs if given an error tuple" do
      response = %{"json_parsing" => "went totally wrong"}

      api_response = {:error, response}

      logging =
        capture_log(fn -> assert ResponseParser.power_status(api_response) == :unknown end)

      assert logging =~ "Failed to parse AWS API response to :power_status request."
      assert logging =~ "Got response: #{inspect(response)}"
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

      assert ResponseParser.power_on(api_response) == :running
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

      assert ResponseParser.power_on(api_response) == :powering_on
    end

    test "unknown if given unparsable jank" do
      response = %{"total_balls" => "jank"}
      api_response = {:ok, response}

      logging = capture_log(fn -> assert ResponseParser.power_on(api_response) == :unknown end)

      assert logging =~ "Failed to parse AWS API response to :power_on request."
      assert logging =~ "Got response: #{inspect(response)}"
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

      assert ResponseParser.power_off(response) == :powered_off
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

      assert ResponseParser.power_off(response) == :powering_off
    end

    test "when it retruns that its powering down" do
      response =
        {:ok,
         %{
           "StoppingInstances" => [
             %{
               "CurrentState" => %{"Name" => "stopping"},
               "PreviousState" => %{"Name" => "running"}
             }
           ]
         }}

      assert ResponseParser.power_off(response) == :powering_off
    end

    test "when given total jank" do
      response = %{"total_balls" => "jank"}
      api_response = {:ok, response}

      logging = capture_log(fn -> assert ResponseParser.power_off(api_response) == :unknown end)

      assert logging =~ "Failed to parse AWS API response to :power_off request."
      assert logging =~ "Got response: #{inspect(response)}"
    end
  end
end
