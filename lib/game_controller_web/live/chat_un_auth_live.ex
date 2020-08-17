defmodule GameControllerWeb.ChatUnAuthLive do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias Phoenix.PubSub
  alias GameController.ChatUnAuth

  def mount(_params, _session, socket) do
    PubSub.subscribe(GameController.PubSub, ChatUnAuth.pub_sub_name())

    socket =
      socket
      |> assign(:messages, ChatUnAuth.messages())
      |> assign(:shift_held, false)
      |> assign(:message, "")
      |> assign(:username, "")

    {:ok, socket}
  end

  def handle_event("username_entered", %{"value" => username}, socket) do
    {:noreply, assign(socket, :username, username)}
  end

  def handle_event("new_message_keydown", %{"key" => key, "value" => message}, socket) do
    case key do
      "Shift" ->
        {:noreply, assign(socket, :shift_held, true)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("new_message_keyup", %{"key" => key, "value" => message}, socket) do
    IO.inspect(socket.assigns.message, label: "message is C")

    case key do
      "Shift" ->
        {:noreply, assign(socket, :shift_held, false)}

      "Enter" ->
        if socket.assigns.shift_held == false and socket.assigns.username != "" and message != "" do
          ChatUnAuth.send_message(%{
            sender: socket.assigns.username,
            payload: message
          })

          IO.inspect("resetting message")
          IO.inspect(socket.assigns.message, label: "message is D")
          {:noreply, assign(socket, :message, "")}
        else
          {:noreply, socket}
        end

      key ->
        {:noreply, assign(socket, :message, message)}
    end
  end

  def handle_info({:messages, messages}, socket) do
    {:noreply, assign(socket, :messages, messages)}
  end
end
