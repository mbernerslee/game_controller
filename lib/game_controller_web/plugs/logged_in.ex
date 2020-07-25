defmodule GameControllerWeb.Plugs.LoggedIn do
  use GameControllerWeb, :controller

  def init(opts) do
    opts
  end

  def call(conn, _opts \\ []) do
    if conn.assigns == %{} do
      conn
      |> redirect(to: Routes.login_path(conn, :show))
      |> halt()
    else
      conn
    end
  end
end
