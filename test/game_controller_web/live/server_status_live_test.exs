defmodule GameControllerWeb.ServerStatusLiveTest do
  use GameControllerWeb.ConnCase, async: false

  # Must be async: false, because all tests are flakey otherwise, since they are all testing the same app-wide genserver
  alias GenServer
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  alias GameController.{RemoteServerStatus, TestSetup}
  alias GameController.RemoteGameServerApi.InMemoryPoweredOn
  alias GameControllerWeb.ServerStatusLive

  @html_apostrophe_s "&apos;s"
  @fecthing_power_status "Fetching power status..."
  @powering_off "Powering him down..."
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
    assert html =~ @powering_off

    refute html =~ @fecthing_power_status
    refute html =~ @powering_on
    refute html =~ @running
  end

  test "powering on when already on", %{conn: conn} do
    GenServer.stop(RemoteServerStatus.genserver_name())

    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :power_on)
    assert html =~ @running

    refute html =~ @fecthing_power_status
    refute html =~ @powering_on
    refute html =~ @powering_off
  end

  test "refreshing the server status", %{conn: conn} do
    GenServer.stop(RemoteServerStatus.genserver_name())

    {:ok, view, _html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    html = render_click(view, :refresh_power_status)
    assert html =~ @fecthing_power_status

    refute html =~ @powering_on
    refute html =~ @powering_off
    refute html =~ @running
  end

  test "shows the time since the server status was last checked", %{conn: conn} do
    :ok = Supervisor.terminate_child(GameController.Supervisor, RemoteServerStatus)
    :ok = Supervisor.delete_child(GameController.Supervisor, RemoteServerStatus)

    {:ok, _pid} =
      Supervisor.start_child(
        GameController.Supervisor,
        {RemoteServerStatus, %{power: :running, seconds_since_power_checked: 121}}
      )

    {:ok, _view, html} =
      conn
      |> TestSetup.logged_in_user_conn()
      |> live(Routes.server_status_path(conn, :show))

    assert html =~ @running
    assert html =~ "last checked 2mins 1s ago"
  end

  describe "display_time/1" do
    test "when less than 60 its seconds" do
      assert ServerStatusLive.display_time(0) == "0s"
      assert ServerStatusLive.display_time(1) == "1s"
      assert ServerStatusLive.display_time(59) == "59s"
    end

    test "when its minutes but less than hours" do
      assert ServerStatusLive.display_time(60) == "1min"
      assert ServerStatusLive.display_time(61) == "1min 1s"
      assert ServerStatusLive.display_time(120) == "2mins"
      assert ServerStatusLive.display_time(121) == "2mins 1s"
      assert ServerStatusLive.display_time(3_599) == "59mins 59s"
    end

    test "when its hours" do
      assert ServerStatusLive.display_time(3_600) == "1hr"
      assert ServerStatusLive.display_time(3_601) == "1hr 1s"
      assert ServerStatusLive.display_time(3_660) == "1hr 1min"
      assert ServerStatusLive.display_time(3_694) == "1hr 1min 34s"
      assert ServerStatusLive.display_time(3_695) == "1hr 1min 35s"
    end

    test "when its days" do
      assert ServerStatusLive.display_time(86_400) == "1day"
      assert ServerStatusLive.display_time(86_401) == "1day 1s"
      assert ServerStatusLive.display_time(172_800) == "2days"
      assert ServerStatusLive.display_time(172_801) == "2days 1s"
      assert ServerStatusLive.display_time(176_461) == "2days 1hr 1min 1s"
      assert ServerStatusLive.display_time(270_000) == "3days 3hrs"
    end
  end
end
