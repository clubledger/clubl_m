defmodule ClubLMWeb.EditPasswordLive do
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
    <.settings_layout current={:edit_password} current_user={@current_user} color_scheme={@color_scheme}>
      <.form let={f} for={@changeset} action={Routes.user_settings_path(@socket, :update_password)}>
        <.form_field
          type="password_input"
          form={f}
          field={:current_password}
          name="current_password"
          label={gettext("Current password")}
        />

        <.form_field
          type="password_input"
          form={f}
          field={:password}
          label={gettext("New password" )}
        />

        <.form_field
          type="password_input"
          form={f}
          field={:password_confirmation}
          label={gettext("New password confirmation")}
        />

        <div class="flex justify-end">
          <.button><%= gettext("Change password") %></.button>
        </div>
      </.form>
    </.settings_layout>
    """
  end

  def handle_event("update_email", %{"user" => user_params}, socket) do
    case Accounts.check_if_can_change_user_email(socket.assigns.current_user, user_params) do
      {:ok, user} ->
        Accounts.deliver_update_email_instructions(
          user,
          user.email,
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
