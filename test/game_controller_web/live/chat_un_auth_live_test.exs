defmodule GameControllerWeb.ChatUnAuthLiveTest do
  use GameControllerWeb.ConnCase, async: false

  # Must be async: false, because all tests are flakey otherwise, since they are all testing the same app-wide genserver
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias GameController.ChatUnAuth

  setup do
    on_exit(fn ->
      Supervisor.terminate_child(GameController.Supervisor, ChatUnAuth)
      Supervisor.restart_child(GameController.Supervisor, ChatUnAuth)
    end)
  end

  test "displaying messages", %{conn: conn} do
    :ok = Supervisor.terminate_child(GameController.Supervisor, ChatUnAuth)
    :ok = Supervisor.delete_child(GameController.Supervisor, ChatUnAuth)

    {:ok, _pid} =
      Supervisor.start_child(
        GameController.Supervisor,
        {ChatUnAuth, %{messages: [%{sender: "Dave", payload: "I'm so cool init"}]}}
      )

    {:ok, _view, html} = live(conn, Routes.chat_un_auth_path(conn, :show))

    document = Floki.parse_document!(html)

    assert document
           |> Floki.find("h1")
           |> Floki.text() == "Chat"

    assert document
           |> Floki.find("li.message")
           |> Floki.text() == "I'm so cool init"
  end
end
