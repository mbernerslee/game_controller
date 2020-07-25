defmodule GameController.Result do
  def and_then({:ok, x}, fun), do: fun.(x)
  def and_then(:ok, fun), do: fun.()
  def and_then(error, _), do: error
end