defmodule GameControllerWeb.TestLoginsControllerTest do
  use GameControllerWeb.ConnCase, async: true

  describe "show/2" do
    test "renders the test logins page", %{conn: conn} do
      assert conn
             |> get(Routes.test_logins_path(conn, :show))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Enum.member?({"h1", [], ["Test account logins"]})
    end
  end
end
