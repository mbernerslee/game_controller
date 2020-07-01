defmodule GameControllerWeb.LoginControllerTest do
  use GameControllerWeb.ConnCase, async: true

  describe "show/2" do
    test "renders the login page", %{conn: conn} do
      assert conn
             |> get(Routes.login_path(conn, :show))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Enum.member?({"h1", [], ["Login page biiitchhhhhhhh!!"]})
    end
  end
end
