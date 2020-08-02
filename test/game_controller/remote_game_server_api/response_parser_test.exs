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
             %{"InstanceState" => %{"Code" => 16, "Name" => "running"}}
           ]
         }}

      assert capture_log(fn ->
               assert ResponseParser.power_status(api_response) == {:ok, :running}
             end) == ""
    end

    test "when two instances are returned its an error" do
      api_response =
        {:ok,
         %{
           "InstanceStatuses" => [
             %{"InstanceState" => %{"Code" => 16, "Name" => "running"}},
             %{"InstanceState" => %{"Code" => 16, "Name" => "running"}}
           ]
         }}

      assert capture_log(fn ->
               assert ResponseParser.power_status(api_response) ==
                        {:error, :more_than_one_instance}
             end) =~ "Found more than 1 instance for the key \"InstanceStatuses\""
    end

    test "when its total jank, its an error" do
      api_response = {:ok, %{"totalJank" => "balls"}}

      assert capture_log(fn ->
               assert ResponseParser.power_status(api_response) ==
                        {:error, :totally_jank_api_response}
             end) =~ "Could not find the key \"InstanceStatuses\" in the API response"
    end

    test "when its an unrecognised instatance state name, its an error" do
      api_response =
        {:ok,
         %{
           "InstanceStatuses" => [
             %{"InstanceState" => %{"Code" => 15, "Name" => "wtf is this name?"}}
           ]
         }}

      assert capture_log(fn ->
               assert ResponseParser.power_status(api_response) ==
                        {:error, :unrecognised_instance_state_name}
             end) =~
               "Did not understand value \"wtf is this name?\" in the key \"InstanceState\" \"Name\""
    end
  end
end
