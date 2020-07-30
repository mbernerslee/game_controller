defmodule GameControllerWeb.LoginControllerTest do
  use GameControllerWeb.ConnCase, async: true

  alias GameController.UserBuilder
  alias GameController.TestSetup

  describe "show/2" do
    test "renders the login page", %{conn: conn} do
      assert conn
             |> get(Routes.login_path(conn, :show))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Enum.member?({"h1", [], ["Login page biiitchhhhhhhh!!"]})
    end

    test "renders only not logged in navbar links", %{conn: conn} do
      navbar_links =
        conn
        |> get(Routes.login_path(conn, :show))
        |> html_response(200)
        |> Floki.parse_document!()
        |> Floki.find("nav")
        |> Floki.find("ul")
        |> Floki.find("li")
        |> Floki.find("a")
        |> Floki.attribute("href")

      assert Enum.member?(navbar_links, Routes.login_path(conn, :show))

      refute Enum.member?(navbar_links, Routes.live_dashboard_path(conn, :home))
    end

    test "renders test logins link in dev or test", %{conn: conn} do
      navbar_links =
        conn
        |> get(Routes.login_path(conn, :show))
        |> html_response(200)
        |> Floki.parse_document!()
        |> Floki.find("nav")
        |> Floki.find("ul")
        |> Floki.find("li")
        |> Floki.find("a")
        |> Floki.attribute("href")

      assert Enum.member?(navbar_links, Routes.test_logins_path(conn, :show))
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = TestSetup.logged_in_user_conn(conn)

      assert conn
             |> TestSetup.logged_in_user_conn()
             |> get(Routes.login_path(conn, :show))
             |> redirected_to(302) == "/"
    end
  end

  describe "create/2" do
    test "on successful login redirects to the main page", %{conn: conn} do
      %{email: email} =
        UserBuilder.build()
        |> UserBuilder.with_password("password")
        |> UserBuilder.insert(returning: [:email])

      conn =
        post(conn, Routes.login_path(conn, :create), %{"email" => email, "password" => "password"})

      assert redirected_to(conn, 302) == Routes.main_page_path(conn, :show)
    end

    test "on successful add the user session to the assigns", %{conn: conn} do
      %{email: email, id: id} =
        UserBuilder.build()
        |> UserBuilder.with_password("password")
        |> UserBuilder.insert(returning: [:email])

      conn =
        post(conn, Routes.login_path(conn, :create), %{"email" => email, "password" => "password"})

      assert conn.assigns == %{user_session: %{id: id, email: email}}
    end

    test "failed login redirects to the login page", %{conn: conn} do
      bad_params = %{"email" => "non_existant_user@example.com", "password" => "x"}
      conn = post(conn, Routes.login_path(conn, :create), bad_params)

      assert redirected_to(conn, 302) == Routes.login_path(conn, :show)
    end
  end
end
