defmodule ClubLMWeb.Components.Navbar do
  @moduledoc """
  A responsive navbar that contains a main menu and dropdown menu (user menu)
  """
  use Phoenix.Component
  alias PetalComponents.Heroicons
  import PetalComponents.{Container, Link, Avatar}
  import ClubLMWeb.Components.{
    Brand,
    UserDropdownMenu,
    ColorSchemeSwitch
  }

  # prop main_menu_items, :list
  # prop user_menu_items, :list
  # prop current_page, :atom
  # prop current_user_name, :any
  # prop avatar_rc, :string
  # prop class, :string
  # prop color_scheme, :string
  def navbar(assigns) do
    assigns =
      assigns
      |> assign_new(:avatar_src, fn -> nil end)
      |> assign_new(:current_user, fn -> nil end)
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div class={"bg-white dark:bg-gray-800 shadow #{@class}"} x-data="{mobileMenuOpen: false}">
      <.container max_width="xl">
        <div class="flex justify-between h-16">
          <div class="flex">
            <a href="/" class="flex items-center flex-shrink-0">
              <div class="hidden lg:block">
                <.logo class="h-8" />
              </div>
              <div class="block lg:hidden">
                <.logo_icon class="w-auto h-8" />
              </div>
            </a>

            <div class="hidden lg:ml-6 lg:flex lg:space-x-8">
              <%= for menu_item <- @main_menu_items do %>
                <.link
                  to={menu_item.path}
                  label={menu_item.label}
                  class={main_menu_item_class(@current_page, menu_item.name)}
                />
              <% end %>
            </div>
          </div>

          <div class="hidden gap-3 lg:ml-6 lg:flex lg:items-center">
            <%= if @color_scheme do %>
              <.color_scheme_switch color_scheme={@color_scheme}/>
            <% end %>

            <%= if Util.present?(@user_menu_items) do %>
              <.user_menu_dropdown
                user_menu_items={@user_menu_items}
                current_user_name={@current_user_name}
              />
            <% end %>
          </div>

          <div class="flex items-center -mr-2 lg:hidden">
            <button
              type="button"
              class="inline-flex items-center justify-center p-2 text-gray-400 rounded-md dark:text-gray-600 hover:text-gray-500 hover:bg-gray-100 dark:hover:text-gray-400 dark:hover:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500"
              aria-controls="mobile-menu"
              @click="mobileMenuOpen = !mobileMenuOpen"
              x-bind:aria-expanded="mobileMenuOpen.toString()"
            >
              <span class="sr-only">
                Open main menu
              </span>

              <div class="w-6 h-6" :class="{ 'hidden': mobileMenuOpen, 'block': !(mobileMenuOpen) }">
                <Heroicons.Outline.menu class="w-6 h-6" />
              </div>

              <div class="w-6 h-6" :class="{ 'block': mobileMenuOpen, 'hidden': !(mobileMenuOpen) }">
                <Heroicons.Outline.x class="w-6 h-6" />
              </div>
            </button>
          </div>
        </div>
      </.container>

      <div
        class="lg:hidden"
        x-cloak="true"
        x-show="mobileMenuOpen"
        x-transition:enter="transition transform ease-out duration-100"
        x-transition:enter-start="transform opacity-0 scale-95"
        x-transition:enter-end="transform opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-75"
        x-transition:leave-start="transform opacity-100 scale-100"
        x-transition:leave-end="transform opacity-0 scale-95"
      >
        <div class="pt-2 pb-3 space-y-1">
          <%= for menu_item <- @main_menu_items do %>
            <.link
              link_type="live_redirect"
              to={menu_item.path}
              label={menu_item.label}
              class={mobile_menu_item_class(@current_page, menu_item.name)}
            />
          <% end %>
        </div>
        <div class="pt-4 pb-3 border-t border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between px-4">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <%= if @current_user_name || @avatar_src do %>
                  <.avatar name={@current_user_name} src={@avatar_src} size="sm" random_color />
                <% else %>
                  <.avatar size="sm" />
                <% end %>
              </div>
              <div class="ml-3">
                <div class="text-base font-medium text-gray-800 dark:text-gray-200">
                  <%= @current_user_name %>
                </div>
              </div>
            </div>

            <%= if @color_scheme do %>
              <.color_scheme_switch color_scheme={@color_scheme}/>
            <% else %>
              <div></div>
            <% end %>
          </div>

          <div class="mt-3 space-y-1">
            <%= for menu_item <- @user_menu_items do %>
              <.link
                link_type="live_redirect"
                to={menu_item.path}
                label={menu_item.label}
                class={mobile_menu_item_class(@current_page, menu_item.name)}
              />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp main_menu_item_class(page, page),
    do: "inline-flex items-center px-1 pt-1
      border-b-2 border-primary-500
      text-sm font-medium leading-5 text-gray-900
      dark:text-gray-100 dark:focus:border-primary-300
      transition duration-150 ease-in-out"

  defp main_menu_item_class(_, _),
    do: "inline-flex items-center px-1 pt-1
      border-b-2 border-transparent
      text-sm font-medium leading-5 text-gray-500
      hover:text-gray-700 hover:border-gray-300
      dark:focus:border-gray-700 dark:hover:text-gray-300 dark:focus:text-gray-300 dark:hover:border-gray-700 dark:text-gray-400
      transition duration-150 ease-in-out"

  defp mobile_menu_item_class(page, page),
    do:
      "block py-2 pl-3 pr-4 text-base font-medium text-primary-700 border-l-4 border-primary-500 bg-primary-50 dark:text-primary-300 dark:bg-primary-700"

  defp mobile_menu_item_class(_, _),
    do:
      "block py-2 pl-3 pr-4 text-base font-medium text-gray-500 border-l-4 border-transparent hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 dark:text-gray-400 dark:bg-gray-800 dark:hover:bg-gray-700 dark:hover:border-gray-700 dark:hover:text-gray-300"
end
