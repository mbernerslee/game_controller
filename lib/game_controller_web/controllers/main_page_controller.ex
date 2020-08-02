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
end
