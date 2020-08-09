defmodule GameControllerWeb.ServerStatusLiveTest do
  use GameControllerWeb.ConnCase, async: true
  alias GenServer
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias GameController.{RemoteServerStatus, TestSetup}

  @html_apostrophe_s "&apos;s"
  @running "He#{@html_apostrophe_s} running"
  @powering_down "He#{@html_apostrophe_s} shutting down...zzzzz"
  @already_on "He#{@html_apostrophe_s} already on dumbass"

  test "loading the page afresh", %{conn: conn} do
    # stopping and restarting it as a way of ensuring its in the "just started up" state. in other words making sure that before we load the page, that power = running in the genserver
    GenServer.stop(RemoteServerStatus.genserver_name())

    {:ok, _view, html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    assert html =~ @running
    refute html =~ @already_on
    refute html =~ @powering_down
  end

  test "powering off", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_off)
    refute html =~ @running
    refute html =~ @already_on
    assert html =~ @powering_down
  end

  test "powering on when already on", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_on)
    refute html =~ @running
    assert html =~ @already_on
    refute html =~ @powering_down
  end
end
