defmodule GameControllerWeb.VerifyEmailController do
  use GameControllerWeb, :controller
  alias GameController.{Users, Auth}

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
