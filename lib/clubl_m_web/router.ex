defmodule ClubLMWeb.Router do
  use ClubLMWeb, :router

  alias ClubLMWeb.Router.Helpers, as: Routes
  import ClubLMWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ClubLMWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug ClubLMWeb.SetLocalePlug, gettext: ClubLMWeb.Gettext
    plug :set_color_scheme
  end

  # Public routes. Though `@current_user` will be available if logged in
  scope "/", ClubLMWeb do
    pipe_through [:browser, :onboard_new_users]
    get "/", PageController, :landing_page

    # Note: The page_builder references like the one below are to help you when building new page pages.
    # To build a page, simply type in the browser URL bar a route you haven't created yet - eg "/contact-us", and fill out the form.
    # You can add/remove page_builder references in the router and they'll show up in the page builder - use the format page_builder:<type>:<name>
    # page_builder:static:public

    live_session :public,
      on_mount: [
        {ClubLMWeb.UserOnMountHooks, :maybe_assign_user},
        {ClubLMWeb.UserOnMountHooks, :assign_color_scheme}
      ] do
      # page_builder:live:public
    end
  end

  # Public routes, but not redirected when a user is logged in but hasn't onboarded
  scope "/", ClubLMWeb do
    pipe_through [:browser]

    delete "/users/sign-out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update

    # Mailbluster must be setup to send users here (see mail_bluster.ex)
    get "/unsubscribe/mailbluster/:email",
        UserSettingsController,
        :unsubscribe_from_mailbluster

    # Mailbluster unsubscribers will end up here
    get "/unsubscribe/marketing",
        UserSettingsController,
        :mailbluster_unsubscribed_confirmation

    get "/unsubscribe/:code/:notification_subscription",
        UserSettingsController,
        :unsubscribe_from_notification_subscription

    put "/unsubscribe/:code/:notification_subscription",
        UserSettingsController,
        :toggle_notification_subscription
  end

  # Public routes only - authenticated users get redirected away. Used for register, sign in, etc
  scope "/", ClubLMWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/sign-in", UserSessionController, :new
    post "/users/sign-in", UserSessionController, :create
    get "/users/reset-password", UserResetPasswordController, :new
    post "/users/reset-password", UserResetPasswordController, :create
    get "/users/reset-password/:token", UserResetPasswordController, :edit
    put "/users/reset-password/:token", UserResetPasswordController, :update
  end

  # Don't force onboarding for onboarding (redirect loop)
  scope "/", ClubLMWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user_for_onboarding,
      on_mount: [
        {ClubLMWeb.UserOnMountHooks, :require_authenticated_user},
        {ClubLMWeb.UserOnMountHooks, :assign_color_scheme}
      ] do
      live "/users/onboarding", UserOnboardingLive
    end
  end

  # Protected routes - authenticated users only
  scope "/", ClubLMWeb do
    pipe_through [
      :browser,
      :require_authenticated_user,
      :kick_user_if_suspended_or_deleted,
      :onboard_new_users
    ]

    # Update password will log a user out and back in, hence can't be in a live view.
    put "/users/settings/update-password", UserSettingsController, :update_password

    # When a user changes their email they'll be sent a link - that link goes to here (which instantly redirects them to their profile page)
    get "/users/settings/confirm-email/:token", UserSettingsController, :confirm_email

    # page_builder:static:protected

    live_session :require_authenticated_user,
      on_mount: [
        {ClubLMWeb.UserOnMountHooks, :require_authenticated_user},
        {ClubLMWeb.UserOnMountHooks, :assign_color_scheme}
      ] do
      live "/users/edit-profile", EditProfileLive
      live "/users/edit-email", EditEmailLive
      live "/users/change-password", EditPasswordLive
      live "/users/edit-notifications", EditNotificationsLive
      live "/app", DashboardLive

      # page_builder:live:protected
    end
  end

  # Admin only routes - used for all things admin related
  scope "/admin", ClubLMWeb do
    pipe_through [
      :browser,
      :require_admin_user,
      :kick_user_if_suspended_or_deleted
    ]

    live_session :require_admin_user,
      on_mount: [
        {ClubLMWeb.UserOnMountHooks, :require_admin_user},
        {ClubLMWeb.UserOnMountHooks, :assign_color_scheme}
      ] do
      live "/users", AdminUsersLive, :index
      live "/users/:user_id", AdminUsersLive, :edit
      live "/logs", LogsLive, :index
      # page_builder:live:admin
    end
  end

  # Development only routes (we include :test to stop "no route defined" warnings happening during testing)
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      # Enables LiveDashboard only for development
      #
      # If you want to use the LiveDashboard in production, you should put
      # it behind authentication and allow only admins to access it.
      # If your application does not have an admins-only section yet,
      # you can use Plug.BasicAuth to set up some basic authentication
      # as long as you are also using SSL (which you should anyway).
      live_dashboard "/dashboard", metrics: ClubLMWeb.Telemetry

      # View sent emails
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      # Show a list of all your apps emails - use this when designing your transactional emails
      scope "/emails" do
        pipe_through([:require_authenticated_user])

        get "/", ClubLMWeb.EmailTestingController, :index
        get "/sent", ClubLMWeb.EmailTestingController, :sent
        get "/preview/:email_name", ClubLMWeb.EmailTestingController, :preview
        post "/send_test_email/:email_name", ClubLMWeb.EmailTestingController, :send_test_email
        get "/show/:email_name", ClubLMWeb.EmailTestingController, :show_html
      end
    end

    scope "/", ClubLMWeb do
      pipe_through :browser

      live_session :dev,
        on_mount: [
          {ClubLMWeb.UserOnMountHooks, :maybe_assign_user},
          {ClubLMWeb.UserOnMountHooks, :assign_color_scheme}
        ] do
        live "/page-builder", PageBuilderLive
        live "/:path_root", PageBuilderLive
        live "/:path_root/:path_child", PageBuilderLive
      end
    end
  end

  # It's common practice to show an onboarding screen for new users
  # - can gather more data on a user
  # - can welcome them to your web app
  # - can give a tutorial on how to use your web app
  defp onboard_new_users(conn, _opts) do
    if conn.assigns[:current_user] && !conn.assigns.current_user.is_onboarded do
      conn
      |> redirect(to: Routes.live_path(conn, ClubLMWeb.UserOnboardingLive))
      |> halt()
    else
      conn
    end
  end

  # Sets @color_scheme on the assigns (this only works for traditional controller actions)
  # For live view it sets it on the session (use {ClubLMWeb.UserOnMountHooks, :assign_color_scheme} as a hook - see https://hexdocs.pm/phoenix_live_view/security-model.html#mounting-considerations)
  defp set_color_scheme(conn, _opts) do
    color_scheme = conn.cookies["color-scheme"] || "dark"

    conn
    |> assign(:color_scheme, color_scheme)
    |> put_session(:color_scheme, color_scheme)
  end
end
