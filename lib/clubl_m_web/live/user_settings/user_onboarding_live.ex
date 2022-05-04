defmodule ClubLMWeb.UserOnboardingLive do
  use ClubLMWeb, :live_view
  alias ClubLM.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{changeset: Accounts.change_profile(socket.assigns.current_user)})}
  end

  def render(assigns) do
    ~H"""
    <div class="fixed inset-0 z-10 overflow-y-auto">
      <div
        class="flex items-end justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0"
      >
        <div class="fixed inset-0 transition-opacity" aria-hidden="true">
          <div class="absolute inset-0 bg-gray-500 opacity-75 dark:bg-gray-800" />
        </div>

        <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">
          &#8203;
        </span>
        <div
          class="inline-block px-4 pt-5 pb-4 overflow-hidden text-left align-bottom transition-all transform bg-white rounded-lg shadow-xl dark:bg-gray-900 sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6"
          role="dialog"
          aria-modal="true"
          aria-labelledby="modal-headline"
        >
          <div>
            <div
              class="flex items-center justify-center w-12 h-12 mx-auto text-2xl bg-green-100 rounded-full dark:bg-green-800"
            >
              👋
            </div>
            <div class="mt-3 text-center sm:mt-5">
              <h3 class="text-xl font-medium leading-6 text-gray-900 dark:text-white" id="modal-headline">
                <%= gettext("Welcome!") %>
              </h3>
              <div class="mt-2 text-base prose-sm text-gray-500 dark:text-gray-400">
                <p>
                  <%= gettext("To join our community, help us improve by completing your profile.") %>
                </p>
              </div>
            </div>
          </div>
          <div class="mt-5 sm:mt-6">
            <.form let={f} for={@changeset} phx-submit="submit">
              <.form_field
                type="text_input"
                form={f}
                field={:name}
                label={gettext("What is your name?*")}
                placeholder={gettext("eg. John")}
                {alpine_autofocus()}
              />

              <.form_field
                type="checkbox"
                form={f}
                field={:is_subscribed_to_marketing_notifications}
                label={gettext("Allow marketing notifications")}
              />

              <div class="flex justify-end">
                <.button><%= gettext("Submit") %></.button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("submit", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "is_onboarded", true)

    case Accounts.update_profile(socket.assigns.current_user, user_params) do
      {:ok, updated_user} ->
        ClubLM.Logs.log_async("update_profile", %{
          user: updated_user,
          profile_user: updated_user
        })

        ClubLM.MailBluster.sync_user_async(updated_user)

        ClubLM.Slack.message("""
        :bust_in_silhouette: *A new user joined!*

        *Name*: #{updated_user.name}
        *Subscribed to marketing emails*: #{updated_user.is_subscribed_to_marketing_notifications}

        #{ClubLMWeb.Endpoint.url()}/admin/users/#{updated_user.id}
        """)

        socket =
          socket
          |> put_flash(:info, gettext("Thank you!"))
          |> push_redirect(to: home_path(updated_user))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, %{changeset: changeset})}
    end
  end
end
