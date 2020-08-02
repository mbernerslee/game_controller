defmodule GameController.RemoteGameServerApi.ResponseParser do
  alias GameController.Result
  require Logger

  def power_status(api_response) do
    api_response
    |> Result.and_then(&do_parse/1)
  end

  defp do_parse(response) do
    case Map.fetch(response, "InstanceStatuses") do
      {:ok, [instance]} ->
        instance
        |> get_in(["InstanceState", "Name"])
        |> parse_instance_state_name(response)

      {:ok, []} ->
        {:ok, :powered_off}

      :error ->
        Logger.error(
          ~s|Could not find the key "InstanceStatuses" in the API response #{inspect(response)}|
        )

        {:error, :totally_jank_api_response}

      {:ok, _wrong} ->
        Logger.error(
          ~s|Found more than 1 instance for the key "InstanceStatuses" in the API response #{
            inspect(response)
          }|
        )

        {:error, :more_than_one_instance}
    end
  end

  defp parse_instance_state_name("running", _) do
    {:ok, :running}
  end

  defp parse_instance_state_name(nil, response) do
    {:error,
     ~s|Could not find the value under the keys "InstanceState", "Name" in "InstanceStatuses" in #{
       response
     } in the API response #{inspect(response)}|}
  end

  defp parse_instance_state_name(_, response) do
    {:ok, :unknown}
  end
end
