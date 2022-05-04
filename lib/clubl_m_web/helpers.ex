defmodule ClubLMWeb.Helpers do
  @moduledoc """
  A set of helpers used in web related views and templates. These functions can be called anywhere in a heex template.
  """
  def main_menu_items(current_user) do
    ClubLMWeb.Menus.main_menu_items(current_user)
  end

  def user_menu_items(current_user) do
    ClubLMWeb.Menus.user_menu_items(current_user)
  end

  def get_menu_item(name, current_user) do
    ClubLMWeb.Menus.get_link(name, current_user)
  end

  def home_path(nil), do: "/"
  def home_path(current_user), do: ClubLMWeb.Menus.get_link(:dashboard, current_user).path

  # Always use this when rendering a user's name
  # This way, if you want to change to something like "user.first_name user.last_name", you only have to change one place
  def user_name(nil), do: nil
  def user_name(user), do: user.name

  def is_admin?(%{is_admin: true}), do: true
  def is_admin?(_), do: false

  # Autofocuses the input
  # <input {alpine_autofocus()} />
  def alpine_autofocus() do
    %{
      "x-data": "",
      "x-init": "$nextTick(() => { $el.focus() });"
    }
  end

  def code_block(code) do
    Phoenix.HTML.raw """
    <pre>#{code}</pre>
    """
  end
end
