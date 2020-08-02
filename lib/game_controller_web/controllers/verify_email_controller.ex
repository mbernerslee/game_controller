defmodule GameControllerWeb.VerifyEmailController do
  use GameControllerWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
