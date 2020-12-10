defmodule HelloSocketsWeb.AuthChannel do
  use Phoenix.Channel
  intercept ["push_timed"]

  alias HelloSockets.Pipeline.Timing

  require Logger

  def join("user:" <> req_user_id, _payload, %{assigns: %{user_id: user_id}} = socket) do
    if req_user_id == to_string(user_id) do
      {:ok, socket}
    else
      Logger.error("#{__MODULE__} failed #{req_user_id} != #{user_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_out("push_timed", %{data: data, at: enqueued_at}, socket) do
    push(socket, "push_timed", data)

    HelloSockets.Statix.histogram(
      "pipeline.push_delivered",
      Timing.unix_ms_now() - enqueued_at
    )

    {:noreply, socket}
  end
end
