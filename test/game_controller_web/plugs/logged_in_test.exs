defmodule GameControllerWeb.Plugs.LoggedInTest do
  use GameControllerWeb.ConnCase, async: true
  alias GameControllerWeb.Plugs.LoggedIn
  alias GameController.TestSetup
  alias Plug.Test

  describe "LoggedIn call/2" do
    test "empty session means not logged in, so conn is halted", %{conn: conn} do
      conn = conn |> Test.init_test_session(%{}) |> LoggedIn.call()
      assert conn.halted
    end

    test "empty session means not logged in, so redirects to login page", %{conn: conn} do
      conn = conn |> Test.init_test_session(%{}) |> LoggedIn.call()
      assert redirected_to(conn, 302) == Routes.login_path(conn, :show)
    end

    test "with valid session does not halt", %{conn: conn} do
      conn = conn |> TestSetup.logged_in_user_conn() |> LoggedIn.call()
      refute conn.halted
    end

    test "with valid session does not redirect", %{conn: conn} do
      conn = conn |> TestSetup.logged_in_user_conn() |> LoggedIn.call()
      assert_raise RuntimeError, fn -> redirected_to(conn) end
    end
  end
end
