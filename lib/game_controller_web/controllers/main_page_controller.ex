defmodule GameControllerWeb.MainPageController do
  use GameControllerWeb, :controller
  alias GameController.Power

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def power_status(conn, _params) do
    Power.status()
    render(conn, "show.html")
  end
end
