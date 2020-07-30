defmodule GameController.UserBuilder do
  alias GameController.{Auth, Repo, UniqueEmailGenerator}

  @verification_key String.duplicate("A", 32)

  def build do
    default_timestamps(%{
      email: UniqueEmailGenerator.generate(),
      password: "password",
      verification_key: @verification_key
    })
  end

  def with_password(user, password) do
    Map.put(user, :password, password)
  end

  def with_non_unqiued_email(user, email) do
    Map.put(user, :email, email)
  end

  def with_email(user, email) do
    email = UniqueEmailGenerator.generate(email)
    Map.put(user, :email, email)
  end

  def insert(user, opts \\ []) do
    returning = Enum.uniq([:id | Keyword.get(opts, :returning, [:id])])

    user =
      user
      |> Map.update!(:password, fn password -> Auth.hash_password(password) end)
      |> default_timestamps()

    {1, [user]} = Repo.insert_all("users", [user], returning: returning)

    if returning == [:id] do
      user.id
    else
      user
    end
  end

  defp default_timestamps(user) do
    now = DateTime.utc_now()
    Map.merge(%{inserted_at: now, updated_at: now}, user)
  end
end
