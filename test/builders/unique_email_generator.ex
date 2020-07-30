defmodule GameController.UniqueEmailGenerator do
  def generate do
    generate("cool_email@domain.com")
  end

  def generate(email) do
    [email, domain] = String.split(email, "@")
    Enum.join([email, System.unique_integer([:positive]), "@", domain])
  end
end
