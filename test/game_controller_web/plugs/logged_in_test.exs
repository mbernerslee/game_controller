defmodule GameControllerWeb.Plugs.LoggedInTest do
  use GameControllerWeb.ConnCase, async: true
  alias GameControllerWeb.Plugs.LoggedIn

  describe "LoggedIn call/2" do
    test "empty assigns means not logged in, so conn is halted", %{conn: conn} do
      assert LoggedIn.call(conn).halted
    end

    test "empty assigns means not logged in, so redirects to login page", %{conn: conn} do
      conn = LoggedIn.call(conn)
      assert redirected_to(conn, 302) == Routes.login_path(conn, :show)
    end
  end
end
