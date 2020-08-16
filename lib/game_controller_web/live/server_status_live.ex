defmodule GameControllerWeb.ServerStatusLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Phoenix.PubSub
  alias GameController.RemoteServerStatus

  def mount(_params, _session, socket) do
    PubSub.subscribe(GameController.PubSub, RemoteServerStatus.pub_sub_name())

    socket =
      socket
      |> assign(:power, RemoteServerStatus.power_status())
      |> assign(:seconds_since_power_checked, RemoteServerStatus.seconds_since_power_checked())

    {:ok, socket}
  end

  def handle_event("refresh_power_status", _, socket) do
    {:noreply, assign(socket, :power, RemoteServerStatus.refresh_power_status())}
  end

  def handle_event("power_on", _, socket) do
    {:noreply, assign(socket, :power, RemoteServerStatus.power_on())}
  end

  def handle_event("power_off", _, socket) do
    {:noreply, assign(socket, :power, RemoteServerStatus.power_off())}
  end

  def handle_info({:power, power}, socket) do
    {:noreply, assign(socket, :power, power)}
  end

  def handle_info({:seconds_since_power_checked, seconds_since_power_checked}, socket) do
    {:noreply, assign(socket, :seconds_since_power_checked, seconds_since_power_checked)}
  end

  @minute_in_seconds 60
  @hour_in_seconds 3600
  @day_in_seconds 86400

  @durations [
    %{singular: "day", plural: "days", unit_in_seconds: @day_in_seconds},
    %{singular: "hr", plural: "hrs", unit_in_seconds: @hour_in_seconds},
    %{singular: "min", plural: "mins", unit_in_seconds: @minute_in_seconds},
    %{singular: "s", plural: "s", unit_in_seconds: 1}
  ]

  def display_time(seconds) do
    @durations
    |> Enum.reduce(
      {[], seconds},
      fn %{unit_in_seconds: unit_in_seconds, plural: plural, singular: singular},
         {output, time} ->
        amount = div(time, unit_in_seconds)
        remainder = rem(time, unit_in_seconds)

        output =
          case amount do
            0 -> output
            1 -> ["1#{singular}" | output]
            _ -> ["#{amount}#{plural}" | output]
          end

        {output, remainder}
      end
    )
    |> elem(0)
    |> Enum.reverse()
    |> Enum.join(" ")
    |> case do
      "" -> "0s"
      non_zero_duration -> non_zero_duration
    end
  end
end
