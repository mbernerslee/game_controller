defmodule GameControllerWeb.MainPageController do
  use GameControllerWeb, :controller
  alias GameController.{RemoteGameServerApi, Result}

  def show(conn, _params) do
    render_show(conn)
  end

  def power_status(conn, _params) do
    RemoteGameServerApi.power_status()
    |> Result.and_then(fn power_status -> render_show(conn, power_status) end)
    |> Result.otherwise(fn _ ->
      raise "Something went seriously wrong. dear god no. Like... I'm seriously you guys"
    end)
  end

  def power_on(conn, _params) do
    RemoteGameServerApi.power_on()
    |> Result.and_then(fn power_status -> render_show(conn, power_status) end)
    |> Result.otherwise(fn _ ->
      raise "Something went seriously wrong. dear god no. Like... I'm seriously you guys"
    end)
  end

  defp render_show(conn, power_status \\ :unknown) do
    render(conn, "show.html", power_status: power_status)
  end
end
