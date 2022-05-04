defmodule ClubLMWeb.Components.PageHelpers do
  use Phoenix.Component
  use PetalComponents

  @doc """
  Allows you to have a heading on the left side, and some action buttons on the right (default slot)

  # prop title, :string
  # slot default
  """
  def page_header(assigns) do
    assigns = assign_new(assigns, :inner_block, fn -> nil end)

    ~H"""
    <div class="mb-8 sm:flex sm:justify-between sm:items-center">
      <div class="mb-4 sm:mb-0">
        <.h2 class="!mb-0">
          <%= @title %>
        </.h2>
      </div>

      <div class="">
        <%= if @inner_block do %>
          <%= render_slot(@inner_block) %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Gives you a white background with shadow.

  prop class, :string
  """
  def box(assigns) do
    assigns =
      assigns
      |> assign_new(:class, fn -> "" end)

    ~H"""
    <div class={"#{@class} bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-lg shadow-lg overflow-hidden"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
