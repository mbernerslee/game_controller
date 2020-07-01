defmodule GameController.Password do
  def hash(password), do: Bcrypt.hash_pwd_salt(password)
  def check(clear_text, hashed), do: Bcrypt.verify_pass(clear_text, hashed)
end
