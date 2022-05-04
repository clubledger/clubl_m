defmodule ClubLM.PageBuilderTest do
  use ExUnit.Case, async: true
  alias ClubLM.PageBuilder

  test "inject_into_line_below" do
    code = """
    scope "/", ClubLMWeb do

      # page_builder:public_static_routes

      live_session :public, on_mount: {ClubLMWeb.UserOnMountHooks, :maybe_assign_user} do
        # page_builder:public_live_routes
      end
    end
    """

    assert PageBuilder.inject_into_line_below(code, "public_static_routes", """
           get "/blah", PageController, :blah
           """) == """
           scope "/", ClubLMWeb do

             # page_builder:public_static_routes
             get "/blah", PageController, :blah

             live_session :public, on_mount: {ClubLMWeb.UserOnMountHooks, :maybe_assign_user} do
               # page_builder:public_live_routes
             end
           end
           """

    assert PageBuilder.inject_into_line_below(code, "public_live_routes", """
           live "/blah", BlahLive
           """) == """
           scope "/", ClubLMWeb do

             # page_builder:public_static_routes

             live_session :public, on_mount: {ClubLMWeb.UserOnMountHooks, :maybe_assign_user} do
               # page_builder:public_live_routes
               live "/blah", BlahLive
             end
           end
           """
  end
end
