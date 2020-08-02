defmodule GameController.RemoteGameServerApi.ResponseParser do
  alias GameController.Result

  def power_status(api_response) do
    Result.and_then(api_response, &do_power_status/1)
  end

  def power_on(api_response) do
    Result.and_then(api_response, &do_power_on/1)
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
        do_power_on(current, previous)

      _ ->
        {:ok, :unknown}
    end
  end

  defp do_power_on(current, previous) do
    case {current, previous} do
      {_, "running"} -> {:ok, :already_on}
      {"pending", "stopped"} -> {:ok, :starting_up}
      _ -> {:ok, :unknown}
    end
  end

  defp do_power_status(response) do
    case response do
      %{"InstanceStatuses" => [%{"InstanceState" => %{"Name" => instance_state}}]} ->
        parse_instance_state_name(instance_state)

      %{"InstanceStatuses" => []} ->
        {:ok, :powered_off}

      _ ->
        {:ok, :unknown}
    end
  end

  defp parse_instance_state_name("running"), do: {:ok, :running}
  defp parse_instance_state_name(_), do: {:ok, :unknown}
end
