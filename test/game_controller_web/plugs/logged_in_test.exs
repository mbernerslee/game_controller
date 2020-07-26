defmodule GameControllerWeb.Plugs.LoggedInTest do
  use GameControllerWeb.ConnCase, async: true
  alias GameControllerWeb.Plugs.LoggedIn
  alias Plug.Test

  @valid_session %{id: 1, email: "test@example/com"}

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
      conn = conn |> Test.init_test_session(@valid_session) |> LoggedIn.call()
      refute conn.halted
    end

    test "with valid session does not redirect", %{conn: conn} do
      conn = conn |> Test.init_test_session(@valid_session) |> LoggedIn.call()
      assert_raise RuntimeError, fn -> redirected_to(conn) end
    end
  end
end
