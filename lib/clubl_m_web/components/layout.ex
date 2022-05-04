defmodule ClubLMWeb.Components.Layout do
  use Phoenix.Component

  import ClubLMWeb.Components.{
    StackedLayout,
    SidebarLayout
  }

  # prop :type, :atom, options: ["stacked", "sidebar"]
  # prop current_page, :atom
  # prop current_user_name, :any
  # prop main_menu_items, :list
  # prop user_menu_items, :list
  # prop avatar_src, :any
  # slot default
  def layout(assigns) do
    ~H"""
    <%= case @type do %>
      <% "sidebar" -> %>
        <.sidebar_layout {assigns}>
          <%= render_slot(@inner_block) %>
        </.sidebar_layout>
      <% "stacked" -> %>
        <.stacked_layout {assigns}>
          <%= render_slot(@inner_block) %>
        </.stacked_layout>
    <% end %>
    """
  end
end
