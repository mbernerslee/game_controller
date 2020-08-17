defmodule GameController.TestSetup do
  alias Plug.Test
  alias Plug.Conn

  @user_session %{id: 1, email: "test@example.com"}

  def logged_in_user_conn(conn, user_session \\ @user_session) do
    conn
    |> Test.init_test_session(user_session)
    |> Conn.assign(:user_session, user_session)
  end

  # Leaving this here as documentation on how to start an otherwise app-wide named genserver as a one off in tests
  # def start_chat_unauth_instance(initial_state) do
  #  id = 8 |> :crypto.strong_rand_bytes() |> Base.encode64()
  #  ExUnit.Callbacks.start_supervised(Supervisor.child_spec({ChatUnAuth, initial_state}, id: id))
  # end
end
