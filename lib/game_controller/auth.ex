defmodule GameController.Auth do
  alias Plug.Conn

  def hash(password), do: Bcrypt.hash_pwd_salt(password)
  def check(clear_text, hashed), do: Bcrypt.verify_pass(clear_text, hashed)

  def set_session(conn, id, email) do
    conn
    |> Conn.fetch_session()
    |> Conn.put_session(:id, id)
    |> Conn.put_session(:email, email)
    |> Conn.assign(:user_session, %{id: id, email: email})
  end

  def has_session?(conn) do
    case conn |> Conn.fetch_session() |> Conn.get_session() do
      %{"id" => _, "email" => _} -> true
      _ -> false
    end
  end
end
