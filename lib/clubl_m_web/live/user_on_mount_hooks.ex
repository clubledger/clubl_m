defmodule ClubLMWeb.UserOnMountHooks do
  @moduledoc """
  This module houses hooks used by live views. A hook is like a plug, but instead of a conn it takes a socket map and can modify the assigns in the socket.
  If can also choose whether to continue to the next hook or halt the process (eg if a user isn't authenticated or something).
  """
  import Phoenix.LiveView
  alias ClubLMWeb.Router.Helpers, as: Routes
  alias ClubLM.Accounts

  def on_mount(:require_authenticated_user, _params, session, socket) do
    socket = maybe_assign_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: Routes.user_session_path(socket, :new))}
    end
  end

  def on_mount(:require_confirmed_user, _params, session, socket) do
    socket = maybe_assign_user(socket, session)

    if socket.assigns.current_user && socket.assigns.current_user.confirmed_at do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: Routes.user_session_path(socket, :new))}
    end
  end

  def on_mount(:require_admin_user, _params, session, socket) do
    socket = maybe_assign_user(socket, session)

    if socket.assigns.current_user && socket.assigns.current_user.is_admin do
      {:cont, socket}
    else
      {:halt, redirect(socket, to: "/")}
    end
  end

  def on_mount(:maybe_assign_user, _params, session, socket) do
    {:cont, maybe_assign_user(socket, session)}
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = maybe_assign_user(socket, session)

    if socket.assigns.current_user do
      {:halt, redirect(socket, to: "/")}
    else
      {:cont, socket}
    end
  end

  def on_mount(:assign_css_theme, _params, session, socket) do
    {:cont, assign(socket, css_theme: session["css_theme"])}
  end

  def on_mount(:assign_color_scheme, _params, session, socket) do
    {:cont, assign(socket, color_scheme: session["color_scheme"])}
  end

  defp maybe_assign_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      get_user(session["user_token"])
    end)
  end

  defp get_user(nil), do: nil
  defp get_user(token), do: Accounts.get_user_by_session_token(token)
end
