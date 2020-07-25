defmodule GameController.UsersTest do
  use GameController.DataCase, async: true

  alias GameController.{Users, UserBuilder}

  describe "users table database structure" do
    test "cannot have two users with the same email address" do
      insert_duplicate_user = fn ->
        UserBuilder.build()
        |> UserBuilder.with_non_unqiued_email("duplicated_email@domain.com")
        |> UserBuilder.insert()
      end

      insert_duplicate_user.()

      assert_raise Postgrex.Error, fn -> insert_duplicate_user.() end
    end
  end

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

      assert :error == Users.login(email, "WRONG PASSWORD!!")
    end

    test "given an NON EXISTANT user email returns error" do
      assert :error == Users.login("jank@email.com", "WRONG PASSWORD!!")
    end
  end
end
