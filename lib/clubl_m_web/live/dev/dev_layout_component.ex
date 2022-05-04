defmodule ClubLMWeb.DevLayoutComponent do
  @moduledoc """
  A layout for any user setting screen like "Change email", "Change password" etc
  """
  use ClubLMWeb, :component

  # prop current_user, :map
  # prop current, :atom
  # slot default
  def dev_layout(assigns) do
    ~H"""
    <.layout
      current_page={@current_page}
      type="sidebar"
      current_user_name={user_name(@current_user)}
      main_menu_items={ClubLMWeb.Menus.build_menu(
        [
          :dev_email_templates,
          :dev_sent_emails,
          :dev_page_builder,
        ],
        @current_user
      )}
      user_menu_items={user_menu_items(@current_user)}
      home_path={home_path(@current_user)}
      color_scheme={@color_scheme}
    >
      <%= render_slot(@inner_block) %>
    </.layout>
    """
  end
end
