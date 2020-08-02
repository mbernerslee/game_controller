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
      assert Enum.member?(navbar_links, Routes.login_path(conn, :delete))
    end
  end

  describe "power_status/2" do
    test "rerenders the main page", %{conn: conn} do
      assert conn
             |> TestSetup.logged_in_user_conn()
             |> post(Routes.main_page_path(conn, :power_status))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Floki.text() ==
               " Yeay. main page mothertruckkerrr "
    end

    test "puts the correct assigns", %{conn: conn} do
      assert %{power_status: :running} =
               conn
               |> TestSetup.logged_in_user_conn()
               |> post(Routes.main_page_path(conn, :power_status))
               |> Map.fetch!(:assigns)
    end
  end

  describe "power_on/2" do
    test "rerenders the main page", %{conn: conn} do
      assert conn
             |> TestSetup.logged_in_user_conn()
             |> post(Routes.main_page_path(conn, :power_on))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Floki.text() ==
               " Yeay. main page mothertruckkerrr "
    end

    test "puts the correct assigns", %{conn: conn} do
      assert %{power_status: :already_on} =
               conn
               |> TestSetup.logged_in_user_conn()
               |> post(Routes.main_page_path(conn, :power_on))
               |> Map.fetch!(:assigns)
    end
  end
end
