defmodule ClubLMWeb.AdminLayoutComponent do
  use ClubLMWeb, :component
  alias ClubLMWeb.Menus

  # prop current_user, :any
  # prop current_page, :atom
  # data tabs, :list
  # slot default
  def admin_layout(assigns) do
    assigns =
      assign_new(assigns, :menu_items, fn ->
        Menus.build_menu(
          [
            :admin_users,
            :logs
          ],
          assigns.current_user
        )
      end)

    ~H"""
    <.layout
      current_page={@current_page}
      type="sidebar"
      sidebar_title="Admin"
      current_user_name={user_name(@current_user)}
      main_menu_items={@menu_items}
      user_menu_items={user_menu_items(@current_user)}
      home_path={home_path(@current_user)}
      color_scheme={@color_scheme}
    >
      <.container max_width="xl" class="my-10">
        <%= render_slot(@inner_block) %>
      </.container>
    </.layout>
    """
  end
end
