defmodule GameControllerWeb.MainPageController do
  use GameControllerWeb, :controller

  def show(conn, _params) do
    IO.inspect("I HIT MainPageController")
    render(conn, "show.html")
  end
end
