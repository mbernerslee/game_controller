defmodule GameController.PowerTest do
  use ExUnit.Case, async: true

  alias GameController.Power

  describe "status/0" do
    test "gets the power status (on or off etc) from the remote server by running the script" do
      assert {:ok, :powered_off} == Power.status()
    end
  end
end
