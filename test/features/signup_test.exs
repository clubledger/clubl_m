defmodule ClubLM.Features.SignupTest do
  use ExUnit.Case
  use Wallaby.Feature
  alias Wallaby.Query
  import Wallaby.Query

  feature "users can create an account", %{session: session} do
    session =
      session
      |> visit("/users/register")
      |> assert_has(Query.text("Register"))
      |> fill_in(text_field("Name"), with: "Bob")
      |> fill_in(text_field("Email"), with: "bob@test.com")
      |> fill_in(text_field("Password"), with: "password")
      |> click(button("Create account"))
      |> assert_has(Query.text("Welcome"))
      |> click(button("Submit"))
      |> assert_has(Query.text("Welcome"))

    assert current_url(session) =~ "/app"
  end
end
