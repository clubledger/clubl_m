defmodule ClubLMWeb.EditNotificationsLive do
  use ClubLMWeb, :live_view
  import ClubLMWeb.UserSettingsLayoutComponent
  alias ClubLM.Accounts
  alias ClubLM.Accounts.User

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       changeset: User.profile_changeset(socket.assigns.current_user)
     )}
  end

  def render(assigns) do
    ~H"""
    <.settings_layout current={:edit_notifications} current_user={@current_user} color_scheme={@color_scheme}>
      <.form let={f} for={@changeset} phx-change="update_profile">
        <.form_field
          type="checkbox"
          form={f}
          field={:is_subscribed_to_marketing_notifications}
          label={gettext("Allow marketing notifications")}
        />
      </.form>
    </.settings_layout>
    """
  end

  def handle_event("update_profile", %{"user" => user_params}, socket) do
    case Accounts.update_profile(socket.assigns.current_user, user_params) do
      {:ok, current_user} ->
        create_log_and_mailbluster_sync(current_user)

        socket =
          socket
          |> put_flash(:info, gettext("Profile updated"))
          |> assign(current_user: current_user, changeset: User.profile_changeset(current_user))

        {:noreply, socket}

      {:error, changeset} ->
        socket =
          socket
          |> put_flash(:error, gettext("Update failed. Please check the form for issues"))
          |> assign(changeset: changeset)

        {:noreply, socket}
    end
  end

  defp create_log_and_mailbluster_sync(user) do
    ClubLM.Logs.log_async("update_profile", %{
      user: user,
      target_user: user
    })

    ClubLM.MailBluster.sync_user_async(user)
  end
end
