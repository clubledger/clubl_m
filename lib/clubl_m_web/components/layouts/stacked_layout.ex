defmodule ClubLMWeb.Components.StackedLayout do
  use Phoenix.Component
  use PetalComponents
  import ClubLMWeb.Components.Navbar

  # prop current_page, :atom
  # prop current_user_name, :any
  # prop main_menu_items, :list
  # prop user_menu_items, :list
  # prop avatar_src, :any
  # slot default
  def stacked_layout(assigns) do
    assigns =
      assigns
      |> assign_new(:main_menu_items, fn -> [] end)
      |> assign_new(:user_menu_items, fn -> [] end)
      |> assign_new(:current_user_name, fn -> nil end)
      |> assign_new(:avatar_src, fn -> nil end)
      |> assign_new(:home_path, fn -> "/" end)
      |> assign_new(:color_scheme, fn -> nil end)

    ~H"""
    <div class="h-screen overflow-y-scroll bg-gray-100 dark:bg-gray-900">
      <.navbar
        current_page={@current_page}
        current_user_name={@current_user_name}
        main_menu_items={@main_menu_items}
        user_menu_items={@user_menu_items}
        home_path={@home_path}
        color_scheme={@color_scheme}
      />

      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
