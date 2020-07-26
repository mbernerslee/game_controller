defmodule GameControllerWeb.Plugs.LoggedOutTest do
  use GameControllerWeb.ConnCase, async: true
  alias GameControllerWeb.Plugs.LoggedOut
  alias GameController.TestSetup
  alias Plug.Test

  describe "LoggedOut call/2" do
    test "empty session means not logged in, so conn is left unaltered", %{conn: conn} do
      conn = conn |> Test.init_test_session(%{}) |> LoggedOut.call()
      refute conn.halted
    end

    test "empty session means not logged in, so conn is not redirected", %{conn: conn} do
      conn = conn |> Test.init_test_session(%{}) |> LoggedOut.call()
      assert_raise RuntimeError, fn -> redirected_to(conn) end
    end

    test "with valid session halts", %{conn: conn} do
      conn = conn |> TestSetup.logged_in_user_conn() |> LoggedOut.call()
      assert conn.halted
    end

    test "with valid session redirects to /", %{conn: conn} do
      conn = conn |> TestSetup.logged_in_user_conn() |> LoggedOut.call()
      assert redirected_to(conn, 302) == "/"
    end
  end
end
