defmodule GameController.UserTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias GameController.User

  @email "email@example.com"
  @password "passworD1"

  @invalid_email [email: {"That's not a real email mate", [validation: :format]}]

  describe "insert_changeset/2" do
    test "with decent email and password changeset is valid" do
      changeset = User.insert_changeset(@email, @password)
      assert %Changeset{valid?: true} = changeset
      assert %User{email: @email} = Changeset.apply_changes(changeset)
    end

    test "password gets hashed sanity check" do
      changeset = User.insert_changeset(@email, @password)
      %{password: actual_password} = Changeset.apply_changes(changeset)

      assert actual_password != @password
    end

    test "must have a valid email address" do
      changeset = User.insert_changeset("bad_email", @password)
      assert @invalid_email = changeset.errors
    end

    test "generates a magic key" do
      changeset = User.insert_changeset(@email, @password)
      assert %User{verification_key: key} = Changeset.apply_changes(changeset)
      assert String.valid?(key)
    end
  end

  @invalid_password [
    password:
      {"Password must be at least 8 characters long and contain at least one number and lower and upper case character",
       [validation: :format]}
  ]

  describe "insert_changeset/2 - password validation" do
    test "at least 8 characters" do
      changeset = User.insert_changeset(@email, "1aA")
      assert @invalid_password = changeset.errors
    end

    test "at least 1 character in upper and lower case" do
      changeset = User.insert_changeset(@email, "password123")
      assert @invalid_password = changeset.errors

      changeset = User.insert_changeset(@email, "PASSWORD123")
      assert @invalid_password = changeset.errors
    end

    test "at least 1 number" do
      changeset = User.insert_changeset(@email, "passworD")
      assert @invalid_password = changeset.errors
    end
  end
end
