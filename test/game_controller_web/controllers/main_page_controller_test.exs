defmodule GameControllerWeb.MainPageControllerTest do
  use GameControllerWeb.ConnCase, async: true

  alias GameController.TestSetup

  describe "show/2" do
    test "renders only not logged in navbar links", %{conn: conn} do
      navbar_links =
        conn
        |> TestSetup.logged_in_user_conn()
        |> get(Routes.main_page_path(conn, :show))
        |> html_response(200)
        |> Floki.parse_document!()
        |> Floki.find("nav")
        |> Floki.find("ul")
        |> Floki.find("li")
        |> Floki.find("a")
        |> Floki.attribute("href")

      refute Enum.member?(navbar_links, Routes.login_path(conn, :show))

      assert Enum.member?(navbar_links, Routes.live_dashboard_path(conn, :home))
    end
  end
end
