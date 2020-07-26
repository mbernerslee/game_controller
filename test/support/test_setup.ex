defmodule GameController.TestSetup do
  alias Plug.Test
  alias Plug.Conn

  @user_session %{id: 1, email: "test@example.com"}

  def logged_in_user_conn(conn) do
    conn
    |> Test.init_test_session(@user_session)
    |> Conn.assign(:user_session, @user_session)
  end
end
