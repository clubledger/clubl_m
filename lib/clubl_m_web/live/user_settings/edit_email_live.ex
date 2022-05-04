defmodule ClubLMWeb.EditEmailLive do
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
    <.settings_layout current={:edit_email} current_user={@current_user} color_scheme={@color_scheme}>
      <.form let={f} for={@changeset} phx-submit="update_email">
        <.form_field
          type="email_input"
          form={f}
          field={:email}
          label={gettext("Change your email")}
          placeholder={gettext("eg. john@gmail.com")}
        />

        <div class="flex justify-end">
          <.button><%= gettext("Change email") %></.button>
        </div>
      </.form>
    </.settings_layout>
    """
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    current_user = socket.assigns.current_user

    case Accounts.check_if_can_change_user_email(current_user, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          current_user.email,
          &Routes.user_settings_url(socket, :confirm_email, &1)
        )

        {:noreply,
         put_flash(
           socket,
           :info,
           gettext("A link to confirm your e-mail change has been sent to the new address.")
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, %{changeset: changeset})}
    end
  end
end
