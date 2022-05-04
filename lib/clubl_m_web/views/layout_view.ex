defmodule ClubLMWeb.LayoutView do
  use ClubLMWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def app_name, do: Application.get_env(:clubl_m, :app_name) || ""

  def title(%{assigns: %{page_title: page_title}}), do: page_title
  def title(_conn), do: app_name()

  def description(%{assigns: %{meta_description: meta_description}}), do: meta_description
  def description(_conn), do: Application.get_env(:clubl_m, :seo_summary) || ""
end
