defmodule ClubLMWeb.UserSettingsLayoutComponent do
  @moduledoc """
  A layout for any user setting screen like "Change email", "Change password" etc
  """
  use ClubLMWeb, :component

  @menu_items [
    :edit_profile,
    :edit_email,
    :edit_password,
    :edit_notifications
  ]

  # prop current_user, :map
  # prop current, :atom
  # slot default
  def settings_layout(assigns) do
    ~H"""
    <.layout
      current_page={@current}
      type="sidebar"
      current_user_name={user_name(@current_user)}
      main_menu_items={main_menu_items(@current_user)}
      user_menu_items={user_menu_items(@current_user)}
      home_path={home_path(@current_user)}
      color_scheme={@color_scheme}
    >
      <.container max_width="xl">
        <.h2 class="py-8">
          Settings
        </.h2>

        <.box class="flex flex-col divide-y divide-gray-200 dark:divide-gray-800 md:divide-y-0 md:divide-x md:flex-row">
          <div class="w-full py-6 md:w-72">
            <%= for menu_item <- menu_items(@current_user) do %>
              <.sidebar_menu_item current={@current} {menu_item} />
            <% end %>
          </div>

          <div class="flex-grow px-4 py-6 sm:p-6 lg:pb-8">
            <%= render_slot(@inner_block) %>
          </div>
        </.box>
      </.container>
    </.layout>
    """
  end

  defp sidebar_menu_item(assigns) do
    assigns = assign_new(assigns, :is_active?, fn -> assigns.current == assigns.name end)

    ~H"""
    <%= live_redirect to: @path,
                  class:
                    menu_item_classes(@is_active?) <>
                      " flex items-center px-3 py-2 text-sm font-medium border-transparent group" do %>
      <Heroicons.Outline.render
        icon={@icon}
        class={menu_item_icon_classes(@is_active?) <> " flex-shrink-0 w-6 h-6 mx-3"}
      />
      <div>
        <%= @label %>
      </div>
    <% end %>
    """
  end

  defp menu_item_classes(true),
    do:
      "bg-primary-50 border-primary-500 text-gray-700 hover:bg-primary-100 dark:bg-primary-900 dark:text-gray-100 dark:hover:bg-primary-800 dark:hover:text-white"

  defp menu_item_classes(false), do: "text-gray-900 hover:bg-gray-50 hover:text-gray-900 dark:text-gray-400 dark:hover:bg-gray-800 dark:hover:text-gray-50"

  defp menu_item_icon_classes(true), do: "text-gray-500 group-hover:text-gray-500 dark:text-gray-100 dark:group-hover:text-white"
  defp menu_item_icon_classes(false), do: "text-gray-500 group-hover:text-gray-500 dark:text-gray-400 dark:group-hover:text-gray-400"

  defp menu_items(current_user) do
    ClubLMWeb.Menus.build_menu(@menu_items, current_user)
  end
end
