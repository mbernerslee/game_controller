defmodule GameController.RemoteServerStatusTest do
  use ExUnit.Case, async: true
  alias GameController.RemoteServerStatus

  # TODO add these tests in a sensible way somehow...?
  describe "power_status/0" do
    test "x" do
      RemoteServerStatus.power_status()
    end
  end
end
