defmodule GameControllerWeb.ServerStatusLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Phoenix.PubSub
  alias GameController.RemoteServerStatus

  def mount(_params, _session, socket) do
    PubSub.subscribe(GameController.PubSub, RemoteServerStatus.pub_sub_name())
    {:ok, assign(socket, :power, RemoteServerStatus.power_status())}
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
end
