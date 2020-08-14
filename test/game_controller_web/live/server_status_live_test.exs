defmodule GameControllerWeb.ServerStatusLiveTest do
  use GameControllerWeb.ConnCase, async: false

  # Must be async: false, because all tests are flakey otherwise, since they are all testing the same app-wide genserver
  alias GenServer
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias GameController.{RemoteServerStatus, TestSetup}
  alias GameController.RemoteGameServerApi.InMemoryPoweredOn

  @html_apostrophe_s "&apos;s"
  @fecthing_power_status "Fetching power status..."
  @powering_down "Powering him down..."
  @powering_on "He#{@html_apostrophe_s} starting up..."
  @running "He#{@html_apostrophe_s} running"

  setup do
    Application.put_env(:game_controller, :remote_game_server_api, InMemoryPoweredOn)
  end

  test "powering off", %{conn: conn} do
    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_off)
    refute html =~ @fecthing_power_status
    refute html =~ @powering_on
    assert html =~ @powering_down
    refute html =~ @running
  end

  test "powering on when already on", %{conn: conn} do
    GenServer.stop(RemoteServerStatus.genserver_name())

    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_on)
    refute html =~ @fecthing_power_status
    refute html =~ @powering_on
    refute html =~ @powering_down
    assert html =~ @running
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
    refute html =~ @running
  end
end
