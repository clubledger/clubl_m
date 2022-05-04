defmodule ClubLMWeb.UserAuth do
  @moduledoc """
  A set of plugs related to user authentication.
  This module is imported into the router and thus any function can be called there as a plug.
  """
  import Plug.Conn
  import Phoenix.Controller
  import ClubLMWeb.Gettext

  alias ClubLM.{Repo, Accounts}
  alias ClubLMWeb.Router.Helpers, as: Routes

  require Logger

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_clubl_m_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)
    {:ok, user} = Accounts.update_last_signed_in_info(user, get_ip(conn))

    ClubLM.Logs.log_async("sign_in", %{user: user})
    ClubLM.MailBluster.sync_user_async(user)

    conn =
      conn
      |> renew_session()
      |> put_session(:user_token, token)
      |> put_session(:user_return_to, nil)
      |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
      |> maybe_write_remember_me_cookie(token, params)

    try do
      redirect(conn, to: user_return_to || signed_in_path(user))
    rescue
      ArgumentError ->
        redirect(conn, to: signed_in_path(user))
    end
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      ClubLMWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    if conn.assigns[:current_user] do
      ClubLM.Logs.log_async("sign_out", %{user: conn.assigns.current_user})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: "/")
  end

  @doc """
  Disconnect a user from any logged in sockets.
  """
  def log_out_another_user(user) do
    Logger.info("Logging out user id #{user.id} ... ")
    users_tokens = Accounts.UserToken.user_and_contexts_query(user, ["session"]) |> Repo.all()

    for user_token <- users_tokens do
      Logger.info("Deleting session token id #{user_token.id} ... ")
      Accounts.delete_session_token(user_token.token)
      live_socket_id = "users_sessions:#{Base.url_encode64(user_token.token)}"
      Logger.info("Disconnecting user id #{user.id}, live_socket_id: #{live_socket_id} ...")
      ClubLMWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if user_token = get_session(conn, :user_token) do
      {user_token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if user_token = conn.cookies[@remember_me_cookie] do
        {user_token, put_session(conn, :user_token, user_token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn.assigns[:current_user]))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, gettext("You must log in to access this page."))
      |> maybe_store_return_to()
      |> redirect(to: Routes.user_session_path(conn, :new))
      |> halt()
    end
  end

  @doc """
  Used for routes that require the user to be a admin
  """
  def require_admin_user(conn, _opts) do
    if conn.assigns[:current_user] && conn.assigns[:current_user].is_admin do
      conn
    else
      conn
      |> put_flash(:error, gettext("You do not have access to this page."))
      |> redirect(to: "/")
      |> halt()
    end
  end

  def kick_user_if_suspended_or_deleted(conn, opts \\ []) do
    if not is_nil(conn.assigns[:current_user]) and
         (conn.assigns[:current_user].is_suspended or
            conn.assigns[:current_user].is_deleted) do
      conn
      |> put_flash(
        :error,
        Keyword.get(opts, :flash, gettext("Your account is not accessible."))
      )
      |> log_out_user
      |> halt()
    else
      conn
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(current_user), do: ClubLMWeb.Helpers.home_path(current_user)

  defp get_ip(conn) do
    # When behind a load balancer, the client ip is provided in the x-forwarded-for header
    # examples:
    # X-Forwarded-For: 2001:db8:85a3:8d3:1319:8a2e:370:7348
    # X-Forwarded-For: 203.0.113.195
    # X-Forwarded-For: 203.0.113.195, 70.41.3.18, 150.172.238.178
    forwarded_for = List.first(Plug.Conn.get_req_header(conn, "x-forwarded-for"))

    if forwarded_for do
      String.split(forwarded_for, ",")
      |> Enum.map(&String.trim/1)
      |> List.first()
    else
      to_string(:inet_parse.ntoa(conn.remote_ip))
    end
  end
end
