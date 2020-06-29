defmodule GameControllerWeb.PageController do
  use GameControllerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
