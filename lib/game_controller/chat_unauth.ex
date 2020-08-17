defmodule GameController.ChatUnAuth do
  use GenServer
  require Logger
  alias Phoenix.PubSub

  @name :chat_unauth
  def genserver_name, do: @name

  def pub_sub_name, do: "chat_unauth"

  @initial_state %{messages: []}

  def start_link(initial_state \\ @initial_state)

  def start_link([]) do
    start_link(@initial_state)
  end

  def start_link(default) when is_map(default) do
    opts =
      if Map.get(default, :no_name, false) do
        []
      else
        [name: @name]
      end

    GenServer.start_link(__MODULE__, default, opts)
  end

  def initial_state do
    Logger.debug("Initialising chat_unauth")
    @initial_state
  end

  def messages(pid \\ @name) do
    GenServer.call(pid, :retrieve_all)
  end

  def send_message(pid \\ @name, %{sender: sender, payload: payload}) do
    GenServer.cast(pid, {:send_message, %{sender: sender, payload: payload}})
  end

  @impl true
  def init(chat_unauth) do
    PubSub.broadcast(GameController.PubSub, pub_sub_name(), {:messages, chat_unauth.messages})
    {:ok, chat_unauth}
  end

  @impl true
  def handle_call(:retrieve_all, _from, chat_unauth) do
    Logger.debug("Retieveing all messages")
    {:reply, chat_unauth.messages, chat_unauth}
  end

  @impl true
  def handle_cast({:send_message, message}, chat_unauth) do
    messages = chat_unauth.messages ++ [message]
    PubSub.broadcast(GameController.PubSub, pub_sub_name(), {:messages, messages})
    {:noreply, %{chat_unauth | messages: messages}}
  end
end
