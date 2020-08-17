defmodule GameController.ChatUnAuthTest do
  use ExUnit.Case, async: true
  alias GameController.{ChatUnAuth, TestSetup}

  describe "start_link/2" do
    test "puts empty message list" do
      {:ok, pid} = TestSetup.start_chat_unauth_instance(%{messages: [], no_name: true})
      assert ChatUnAuth.messages(pid) == []
    end
  end
end
