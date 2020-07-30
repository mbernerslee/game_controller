defmodule GameController.AllowedUserEmailsBuilder do
  alias GameController.{Auth, Repo, UniqueEmailGenerator}

  def build do
    default_timestamps(%{email: UniqueEmailGenerator.generate()})
  end

  def with_non_unqiued_email(record, email) do
    Map.put(record, :email, email)
  end

  def with_email(record, email) do
    email = UniqueEmailGenerator.generate(email)
    Map.put(record, :email, email)
  end

  def insert_arbitrary(opts \\ []) do
    insert(build(), opts)
  end

  def insert(record, opts \\ []) do
    returning = Enum.uniq([:id | Keyword.get(opts, :returning, [:id])])

    record = default_timestamps(record)

    {1, [record]} = Repo.insert_all("allowed_user_emails", [record], returning: returning)

    if returning == [:id] do
      record.id
    else
      record
    end
  end

  defp default_timestamps(record) do
    now = DateTime.utc_now()
    Map.merge(%{inserted_at: now, updated_at: now}, record)
  end
end
