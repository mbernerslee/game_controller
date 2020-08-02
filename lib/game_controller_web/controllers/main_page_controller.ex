defmodule GameControllerWeb.MainPageController do
  use GameControllerWeb, :controller
  alias GameController.{RemoteGameServerApi, Result}

  def show(conn, _params) do
    render(conn, "show.html", power_status: :unknown)
  end

  def power_status(conn, _params) do
    RemoteGameServerApi.power_status()
    |> Result.and_then(fn power_status ->
      render(conn, "show.html", power_status: power_status)
    end)
    |> Result.otherwise(fn _ ->
      raise "Something went seriously wrong. dear god no. Like... I'm seriously you guys"
    end)
  end

  def power_on(conn, _params) do
    RemoteGameServerApi.power_on()
    |> Result.and_then(fn power_on ->
      %{"StartingInstances" =>
	[
	  %{"CurrentState" => %{"Name" => current},
	    "PreviousState" => %{"Name" => previous},
	   }
	]
       } = power_on
	{power_status, power_on} = 
	  case {previous, current} do
	    {_, "running"} -> {:running, :already_on}
	    {"stopped", "pending"} -> {:starting_up, :starting_up}
	    _ -> {:unknown, :unknown}
	  end
      render(conn, "show.html", power_status: power_status, power_on: power_on)
    end)
    |> Result.otherwise(fn _ ->
      raise "Something went seriously wrong. dear god no. Like... I'm seriously you guys"
    end)
  end
end
