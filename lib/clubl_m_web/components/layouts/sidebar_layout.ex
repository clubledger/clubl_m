defmodule ClubLMWeb.Components.SidebarLayout do
  @moduledoc """
  A responsive layout with a left sidebar (main menu), as well as a drop down menu up the top right (user menu).
  """
  use Phoenix.Component
  use PetalComponents

  import ClubLMWeb.Components.{
    Brand,
    UserDropdownMenu,
    ColorSchemeSwitch
  }

  # prop current_page, :atom
  # prop current_user_name, :string
  # prop avatar_src, :string
  # prop sidebar_title, :string
  # prop home_path, :string
  # slot default
  def sidebar_layout(assigns) do
    assigns =
      assigns
      |> assign_new(:main_menu_items, fn -> [] end)
      |> assign_new(:user_menu_items, fn -> [] end)
      |> assign_new(:avatar_src, fn -> nil end)
      |> assign_new(:sidebar_title, fn -> "Pages" end)
      |> assign_new(:home_path, fn -> "/" end)
      |> assign_new(:color_scheme, fn -> nil end)

    ~H"""
    <div class="flex h-screen overflow-hidden bg-gray-100 dark:bg-gray-900" x-data="{sidebarOpen: false}">
      <.sidebar
        current_page={@current_page}
        main_menu_items={@main_menu_items}
        sidebar_title={@sidebar_title}
        home_path={@home_path}
      />

      <div class="relative flex flex-col flex-1 pb-32 overflow-x-auto overflow-y-auto lg:pb-0">
        <.topbar
          current_page={@current_page}
          user_menu_items={@user_menu_items}
          avatar_src={@avatar_src}
          current_user_name={@current_user_name}
          color_scheme={@color_scheme}
        />

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def topbar(assigns) do
    ~H"""
    <header class="sticky top-0 z-30 bg-white border-b border-gray-200 dark:bg-gray-900 dark:border-gray-800">
      <div class="px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16 -mb-px">
          <div class="flex min-w-[68px]">
            <button
              class="text-gray-500 hover:text-gray-600 lg:hidden"
              @click.stop="sidebarOpen = !sidebarOpen"
              aria-controls="sidebar"
              :aria-expanded="sidebarOpen"
            >
              <span class="sr-only">
                Open sidebar
              </span>
              <svg class="w-6 h-6 fill-current" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <rect x="4" y="5" width="16" height="2" />
                <rect x="4" y="11" width="16" height="2" />
                <rect x="4" y="17" width="16" height="2" />
              </svg>
            </button>
          </div>

          <div class="flex items-center gap-3">
            <%= if @color_scheme do %>
              <.color_scheme_switch color_scheme={@color_scheme}/>
            <% end %>

            <%= if Util.present?(@user_menu_items) do %>
              <.user_menu_dropdown
                user_menu_items={@user_menu_items}
                avatar_src={@avatar_src}
                current_user_name={@current_user_name}
              />
            <% end %>
          </div>
        </div>
      </div>
    </header>
    """
  end

  def sidebar(assigns) do
    ~H"""
    <div class="z-50 shadow lg:w-64">
      <div
        class="fixed inset-0 z-40 transition-opacity duration-200 bg-gray-900 bg-opacity-30 lg:hidden lg:z-auto"
        :class="sidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'"
        aria-hidden="true"
        x-cloak
      ></div>

      <div
        id="sidebar"
        class="absolute top-0 left-0 z-40 flex-shrink-0 w-64 h-screen p-4 overflow-y-scroll transition-transform duration-200 ease-in-out transform bg-gray-800 lg:static lg:left-auto lg:top-auto lg:translate-x-0 lg:overflow-y-auto no-scrollbar"
        :class="sidebarOpen ? 'translate-x-0' : '-translate-x-64'"
        @click.away="sidebarOpen = false"
        @keydown.escape.window="sidebarOpen = false"
        x-cloak="lg"
      >
        <div class="flex justify-between pr-3 mb-10 sm:px-2">
          <button
            class="text-gray-500 lg:hidden hover:text-gray-400"
            @click.stop="sidebarOpen = !sidebarOpen"
            aria-controls="sidebar"
            :aria-expanded="sidebarOpen"
          >
            <span class="sr-only">
              Close sidebar
            </span>
            <svg class="w-6 h-6 fill-current" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M10.7 18.7l1.4-1.4L7.8 13H20v-2H7.8l4.3-4.3-1.4-1.4L4 12z" />
            </svg>
          </button>

          <a href={@home_path} class="block">
            <.logo
              variant="light"
              class="h-8 transition-transform duration-300 ease-out transform hover:scale-105"
            />
          </a>
        </div>

        <div>
          <h3 class="pl-3 mb-3 text-xs font-semibold text-gray-400 uppercase">
            <%= @sidebar_title %>
          </h3>

          <nav aria-label="Sidebar" class="divide-y divide-gray-300">
            <div class="pb-8 space-y-1">
              <%= for menu_item <- @main_menu_items do %>
                <.link
                  link_type="live_redirect"
                  to={menu_item.path}
                  class={menu_item_classes(@current_page, menu_item.name)}
                >
                  <Heroicons.Outline.render icon={menu_item.icon} class="w-5 h-5" />

                  <span class="ml-3">
                    <%= menu_item.label %>
                  </span>
                </.link>
              <% end %>
            </div>
          </nav>
        </div>
      </div>
    </div>
    """
  end

  def link_class(),
    do:
      "flex items-center px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 hover:text-gray-900"

  # Active state
  def menu_item_classes(page, page),
    do:
      "flex items-center px-3 py-2 text-sm font-medium text-gray-200 bg-gray-900 hover:text-gray-200 rounded-md group"

  # Inactive state
  def menu_item_classes(_current_page, _link_page),
    do:
      "flex items-center px-3 py-2 text-sm font-medium text-gray-200 hover:text-white hover:bg-gray-500 rounded-md group"
end
