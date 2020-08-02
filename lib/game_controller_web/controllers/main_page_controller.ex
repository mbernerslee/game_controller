defmodule GameControllerWeb.MainPageController do
  use GameControllerWeb, :controller
  alias GameController.{RemoteGameServerApi, Result, RemoteServerStatus}

  def show(conn, _params) do
    render_show(conn)
  end

  def power_status(conn, _params) do
    handle_power_post(conn, &RemoteGameServerApi.power_status/0)
  end

  def power_on(conn, _params) do
    handle_power_post(conn, &RemoteGameServerApi.power_on/0)
  end

  defp handle_power_post(conn, fun) do
    fun.()
    |> Result.and_then(fn power_status ->
      RemoteServerStatus.update(:power, power_status)
      render_show(conn)
    end)
    |> Result.otherwise(fn _ ->
      raise "Something went seriously wrong. dear god no. Like... I'm seriously you guys"
    end)
  end

  defp render_show(conn) do
    render(conn, "show.html", power_status: RemoteServerStatus.get(:power))
  end
end
