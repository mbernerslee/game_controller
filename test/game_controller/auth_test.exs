defmodule GameControllerWeb.AuthTest do
  use GameControllerWeb.ConnCase, async: true
  alias GameController.Auth
  alias Plug.Test

  describe "set_session/3" do
    test "adds the session", %{conn: conn} do
      conn = conn |> Test.init_test_session(%{}) |> Auth.set_session(1, "test@example.com")
      assert get_session(conn) == %{"email" => "test@example.com", "id" => 1}
    end

    test "adds the session to the assigns", %{conn: conn} do
      conn = conn |> Test.init_test_session(%{}) |> Auth.set_session(1, "test@example.com")
      assert conn.assigns == %{user_session: %{email: "test@example.com", id: 1}}
    end
  end

  describe "has_session?/1" do
    test "true if it has it, otherwise false", %{conn: conn} do
      refute conn |> Test.init_test_session(%{}) |> Auth.has_session?()
      refute conn |> Test.init_test_session(%{id: 1}) |> Auth.has_session?()
      refute conn |> Test.init_test_session(%{email: "x@x.com"}) |> Auth.has_session?()
      assert conn |> Test.init_test_session(%{id: 1, email: "x@x.com"}) |> Auth.has_session?()
    end
  end
end
