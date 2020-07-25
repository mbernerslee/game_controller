defmodule GameControllerWeb.AuthTest do
  use GameControllerWeb.ConnCase, async: true
  alias GameController.Auth

  describe "set_session/3" do
    test "adds the session", %{conn: conn} do
      conn =
        conn
        |> Auth.set_session(conn, 1, "some_email@example.com")

      conn
      |> fetch_session()
      |> get_session()
      |> IO.inspect()
    end
  end
end
