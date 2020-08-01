defmodule GameControllerWeb.SignupControllerTest do
  use GameControllerWeb.ConnCase, async: true

  alias GameController.{UserBuilder, AllowedUserEmailsBuilder}

  describe "show/2" do
    test "renders the signup page", %{conn: conn} do
      assert conn
             |> get(Routes.signup_path(conn, :show))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Enum.member?({"h1", [], ["Signup page Duuuuuuuddeee!!"]})
    end

    test "renders the link to signup in the navbar", %{conn: conn} do
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

      assert Enum.member?(navbar_links, Routes.signup_path(conn, :show))
    end
  end

  @password "passworD1"

  describe "create/2" do
    test "if an allowed email is in the DB, creates the user & redirects to the verify email page",
         %{conn: conn} do
      %{email: email} = AllowedUserEmailsBuilder.insert_arbitrary(returning: [:email])

      conn =
        post(conn, Routes.signup_path(conn, :create), %{
          "user" => %{
            "email" => email,
            "password" => @password
          }
        })

      assert redirected_to(conn, 302) == Routes.verify_email_path(conn, :show)
    end

    test "if the email is not allowed in the DB, they're rejected", %{conn: conn} do
      conn =
        post(conn, Routes.signup_path(conn, :create), %{
          "user" => %{
            "email" => "some_not_allowed_email@example.com",
            "password" => @password
          }
        })

      assert redirected_to(conn, 302) == Routes.signup_path(conn, :show)
    end

    test "if an allowed email is in the DB, but already exists in the db, they're rejected",
         %{conn: conn} do
      %{email: email} = AllowedUserEmailsBuilder.insert_arbitrary(returning: [:email])

      UserBuilder.build()
      |> UserBuilder.with_non_unqiued_email(email)
      |> UserBuilder.with_password(@password)
      |> UserBuilder.insert()

      conn =
        post(conn, Routes.signup_path(conn, :create), %{
          "user" => %{
            "email" => email,
            "password" => @password
          }
        })

      assert redirected_to(conn, 302) == Routes.signup_path(conn, :show)
    end

    test "given an allowed email but invalid password, shows the errors",
         %{conn: conn} do
      %{email: email} = AllowedUserEmailsBuilder.insert_arbitrary(returning: [:email])

      conn =
        post(conn, Routes.signup_path(conn, :create), %{
          "user" => %{
            "email" => email,
            "password" => "bad"
          }
        })

      assert html_response(conn, 200)
    end
  end
end
