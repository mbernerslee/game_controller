defmodule GameController.Password do
  alias Plug.Conn

  # TODO rename this module to Auth and rename the functions
  def hash(password), do: Bcrypt.hash_pwd_salt(password)
  def check(clear_text, hashed), do: Bcrypt.verify_pass(clear_text, hashed)

  def add_user_session(conn, id, email) do
    Conn.assign(conn, :user_session, %{id: id, email: email})
  end
end
