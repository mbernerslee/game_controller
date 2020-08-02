defmodule GameController.RemoteGameServerApi.RealApiTest do
  use ExUnit.Case, async: true

  alias GameController.RemoteGameServerApi.RealApi

  @moduletag :remote_game_server_real_api

  describe "status/0" do
    test "gets the power status (on or off etc) from the remote server by running the script" do
      # assert {:ok, :powered_off} == RealApi.power_status()
      assert RealApi.power_status() == {:ok, :running}
    end
  end
end
