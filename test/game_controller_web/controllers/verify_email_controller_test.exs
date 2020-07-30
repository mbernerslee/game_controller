defmodule GameControllerWeb.VerifyEmailControllerTest do
  use GameControllerWeb.ConnCase, async: true

  describe "show/2" do
    test "renders the verify email page", %{conn: conn} do
      assert conn
             |> get(Routes.verify_email_path(conn, :show))
             |> html_response(200)
             |> Floki.parse_document!()
             |> Floki.find("h1")
             |> Enum.member?({"h1", [], ["Verify email address..."]})
    end
  end
end
