defmodule GameControllerWeb.ServerStatusLiveTest do
  use GameControllerWeb.ConnCase, async: true
  alias GenServer
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias GameController.{RemoteServerStatus, TestSetup}

  @html_apostrophe_s "&apos;s"
  @fecthing_power_status "Fetching power status..."
  @powering_down "Powering him down..."
  @powering_on "He#{@html_apostrophe_s} starting up..."

  test "powering off", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_off)
    refute html =~ @fecthing_power_status
    refute html =~ @powering_on
    assert html =~ @powering_down
  end

  test "powering on when already on", %{conn: conn} do
    GenServer.stop(RemoteServerStatus.genserver_name())

    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_on)
    refute html =~ @fecthing_power_status
    assert html =~ @powering_on
    refute html =~ @powering_down
  end

  test "refreshing the server status", %{conn: conn} do
    GenServer.stop(RemoteServerStatus.genserver_name())

    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :refetch_power_status)
    assert html =~ @fecthing_power_status
    refute html =~ @powering_on
    refute html =~ @powering_down
  end
end
