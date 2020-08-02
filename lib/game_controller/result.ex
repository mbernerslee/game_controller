defmodule GameController.Result do
  def and_then({:ok, x}, fun), do: fun.(x)
  def and_then(:ok, fun), do: fun.()
  def and_then(error, _), do: error
  def otherwise({:error, reason}, fun), do: fun.(reason)
  def otherwise(other, _), do: other
end
