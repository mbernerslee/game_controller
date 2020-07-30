defmodule GameController.UsersTest do
  use GameController.DataCase, async: true

  alias Ecto.Changeset
  alias GameController.{Users, UserBuilder, AllowedUserEmailsBuilder, User}

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

  @valid_password "passworD1"

  describe "signup/2" do
    test "with an allowed user email in the DB and no existing user, creates the user" do
      %{email: email} = AllowedUserEmailsBuilder.insert_arbitrary(returning: [:email])
      assert {:ok, user} = Users.signup(email, @valid_password)

      actual_user = Repo.one!(from u in User, where: u.email == ^email)
      assert actual_user.verification_key
      assert actual_user.password
    end

    test "when all is allowed but its clearly a jank email, return errored changeset" do
      %{email: email} =
        AllowedUserEmailsBuilder.build()
        |> AllowedUserEmailsBuilder.with_non_unqiued_email("not_a_valid_email")
        |> AllowedUserEmailsBuilder.insert(returning: [:email])

      assert {:error, %Changeset{}} = Users.signup(email, @valid_password)
    end

    test "when erroring because user already exists returns :error" do
      %{email: email} = AllowedUserEmailsBuilder.insert_arbitrary(returning: [:email])

      UserBuilder.build()
      |> UserBuilder.with_non_unqiued_email(email)
      |> UserBuilder.with_password(@valid_password)
      |> UserBuilder.insert()

      assert :error = Users.signup(email, @valid_password)
    end

    test "when erroring because user email isn't allowed returns :error" do
      assert :error = Users.signup("valid_email@domain.com", @valid_password)
    end
  end
end
