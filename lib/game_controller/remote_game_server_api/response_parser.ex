defmodule GameController.RemoteGameServerApi.ResponseParser do
  alias GameController.Result
  require Logger

  def power_status(api_response) do
    parse_action(api_response, &do_power_status/1, __ENV__.function)
  end

  def power_on(api_response) do
    parse_action(api_response, &do_power_on/1, __ENV__.function)
  end

  def power_off(api_response) do
    parse_action(api_response, &do_power_off/1, __ENV__.function)
  end

  defp parse_action(api_response, parser_fun, {function, _}) do
    api_response
    |> Result.and_then(parser_fun)
    |> Result.otherwise(fn error ->
      Logger.error(
        "Failed to parse AWS API response to #{inspect(function)} request. Got response: #{
          inspect(error)
        }"
      )

      :unknown
    end)
  end

  defp do_power_off(response) do
    case response do
      %{
        "StoppingInstances" => [
          %{
            "CurrentState" => %{"Name" => current},
            "PreviousState" => %{"Name" => previous}
          }
        ]
      } ->
        parse_power_off_instance_state(previous, current, response)

      _ ->
        {:error, response}
    end
  end

  defp parse_power_off_instance_state(previous, current, response) do
    case {previous, current} do
      {"stopped", "stopped"} ->
        :powered_off

      {"running", "stopping"} ->
        :powering_off

      {"running", "stopped"} ->
        :powering_off

      _ ->
        {:error, response}
    end
  end

  defp do_power_on(response) do
    case response do
      %{
        "StartingInstances" => [
          %{
            "CurrentState" => %{"Name" => current},
            "PreviousState" => %{"Name" => previous}
          }
        ]
      } ->
        do_power_on(current, previous, response)

      _ ->
        {:error, response}
    end
  end

  defp do_power_on(current, previous, response) do
    case {current, previous} do
      {_, "running"} -> :running
      {"pending", "stopped"} -> :powering_on
      _ -> {:error, response}
    end
  end

  defp do_power_status(response) do
    case response do
      %{"InstanceStatuses" => [%{"InstanceState" => %{"Name" => instance_state}}]} ->
        parse_instance_state_name(instance_state, response)

      %{"InstanceStatuses" => []} ->
        :powered_off

      _ ->
        {:error, response}
    end
  end

  defp parse_instance_state_name("running", _), do: :running
  defp parse_instance_state_name(_, response), do: {:error, response}
end
