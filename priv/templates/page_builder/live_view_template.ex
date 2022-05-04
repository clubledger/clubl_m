defmodule ClubLMWeb.<%= @module_name %> do
  use ClubLMWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.layout
      current_page={:<%= @menu_item_name %>}
      type="<%= @layout %>"
      current_user_name={user_name(@current_user)}
      main_menu_items={main_menu_items(@current_user)}
      user_menu_items={user_menu_items(@current_user)}
      home_path={home_path(@current_user)}
      color_scheme={@color_scheme}
    >
      <.container max_width="xl" class="my-10">
        <.h2><%= @title %></.h2>
      </.container>
    </.layout>
    """
  end
end
