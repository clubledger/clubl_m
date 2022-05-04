defmodule ClubLMWeb.Menus do
  @moduledoc """
  Describe all of your navigation menus in here. This keeps you from having to define them in a layout template
  """
  import ClubLMWeb.Gettext
  alias ClubLMWeb.Router.Helpers, as: Routes
  alias ClubLMWeb.Endpoint
  alias ClubLMWeb.Helpers

  # Signed out main menu
  def main_menu_items(nil),
    do:
      build_menu([])

  # Signed in main menu
  def main_menu_items(current_user),
    do:
      build_menu(
        [
          :dashboard
        ],
        current_user
      )

  # Signed out user menu
  def user_menu_items(nil),
    do:
      build_menu(
        [
          :sign_in,
          :register
        ],
        nil
      )

  # Signed in user menu
  def user_menu_items(current_user),
    do:
      build_menu(
        [
          :settings,
          :admin,
          :dev,
          :sign_out
        ],
        current_user
      )

  def build_menu(menu_items, current_user \\ nil),
    do: Enum.map(menu_items, &get_link(&1, current_user)) |> Enum.filter(& &1)

  def get_link(name, current_user \\ nil)

  def get_link(:register, _current_user) do
    %{
      name: :register,
      label: "Register",
      path: Routes.user_registration_path(Endpoint, :new),
      icon: :clipboard_list
    }
  end

  def get_link(:sign_in, _current_user) do
    %{
      name: :sign_in,
      label: "Sign in",
      path: Routes.user_session_path(Endpoint, :new),
      icon: :key
    }
  end

  def get_link(:sign_out, _current_user) do
    %{
      name: :sign_out,
      label: "Sign out",
      path: Routes.user_session_path(Endpoint, :delete),
      icon: :logout,
      method: :delete
    }
  end

  def get_link(:settings, _current_user) do
    %{
      name: :settings,
      label: gettext("Settings"),
      path: Routes.live_path(Endpoint, ClubLMWeb.EditProfileLive),
      icon: :cog
    }
  end

  def get_link(:edit_profile, _current_user) do
    %{
      name: :edit_profile,
      label: gettext("Edit profile"),
      path: Routes.live_path(Endpoint, ClubLMWeb.EditProfileLive),
      icon: :user_circle
    }
  end

  def get_link(:edit_email, _current_user) do
    %{
      name: :edit_email,
      label: gettext("Change email"),
      path: Routes.live_path(Endpoint, ClubLMWeb.EditEmailLive),
      icon: :at_symbol
    }
  end

  def get_link(:edit_notifications, _current_user) do
    %{
      name: :edit_notifications,
      label: gettext("Edit notifications"),
      path: Routes.live_path(Endpoint, ClubLMWeb.EditNotificationsLive),
      icon: :bell
    }
  end

  def get_link(:edit_password, _current_user) do
    %{
      name: :edit_password,
      label: gettext("Edit password"),
      path: Routes.live_path(Endpoint, ClubLMWeb.EditPasswordLive),
      icon: :key
    }
  end

  def get_link(:dashboard, _current_user) do
    %{
      name: :dashboard,
      label: gettext("Dashboard"),
      path: Routes.live_path(Endpoint, ClubLMWeb.DashboardLive),
      icon: :template
    }
  end

  def get_link(:admin, current_user) do
    link = get_link(:admin_users, current_user)

    if link do
      link
      |> Map.put(:label, "Admin")
      |> Map.put(:icon, :lock_closed)
    else
      nil
    end
  end

  def get_link(:admin_users = name, current_user) do
    if Helpers.is_admin?(current_user) do
      %{
        name: name,
        label: "Users",
        path: Routes.admin_users_path(Endpoint, :index),
        icon: :users
      }
    else
      nil
    end
  end

  def get_link(:logs = name, current_user) do
    if Helpers.is_admin?(current_user) do
      %{
        name: name,
        label: "Logs",
        path: Routes.logs_path(Endpoint, :index),
        icon: :eye
      }
    else
      nil
    end
  end

  def get_link(:dev, current_user) do
    dev_link = get_link(:dev_email_templates, current_user)

    if dev_link do
      Map.merge(dev_link, %{
        label: "Dev",
        name: :dev,
        icon: :code
      })
    else
      nil
    end
  end

  def get_link(:dev_email_templates = name, _current_user) do
    if Application.get_env(:clubl_m, :env) == :dev do
      %{
        name: name,
        label: "Email templates",
        path: "/dev/emails",
        icon: :template
      }
    else
      nil
    end
  end

  def get_link(:dev_sent_emails = name, _current_user) do
    if Application.get_env(:clubl_m, :env) == :dev do
      %{
        name: name,
        label: "Sent emails",
        path: "/dev/emails/sent",
        icon: :at_symbol
      }
    else
      nil
    end
  end

  def get_link(:dev_page_builder = name, _current_user) do
    if Application.get_env(:clubl_m, :env) == :dev do
      %{
        name: name,
        label: "Page builder",
        path: Routes.live_path(Endpoint, ClubLMWeb.PageBuilderLive),
        icon: :document_add
      }
    else
      nil
    end
  end
end
