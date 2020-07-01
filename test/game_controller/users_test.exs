defmodule GameController.UsersTest do
  use GameController.DataCase, async: true

  alias GameController.{Users, UserBuilder}

  describe "login/2" do
    test "given an existing user's email and correct password, logs them in" do
      %{id: id, email: email} =
        UserBuilder.build()
        |> UserBuilder.with_password("password")
        |> UserBuilder.insert(returning: [:id, :email, :password])

      assert {:ok, %{id: id, email: email}} == Users.login(email, "password")
    end

    test "given an existing user's email and the WRONG password returns error" do
      %{email: email} =
        UserBuilder.build()
        |> UserBuilder.with_password("password")
        |> UserBuilder.insert(returning: [:id, :email, :password])

      assert {:error, :wrong_password} == Users.login(email, "WRONG PASSWORD!!")
    end

    test "given an NON EXISTANT user email returns error" do
      assert {:error, :user_not_found_by_email} ==
               Users.login("jank@email.com", "WRONG PASSWORD!!")
    end
  end
end
