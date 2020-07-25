defmodule GameController.Auth do
  alias Plug.Conn

  # TODO rename these functions to say that its password stuff
  def hash(password), do: Bcrypt.hash_pwd_salt(password)
  def check(clear_text, hashed), do: Bcrypt.verify_pass(clear_text, hashed)

  def set_session(conn, id, email) do
    # Conn.assign(conn, :user_session, %{id: id, email: email})
    conn
    |> Conn.fetch_session()
    |> Conn.put_session(:id, id)
    |> Conn.put_session(:email, email)
  end
end
