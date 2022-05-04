defmodule ClubLM.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ClubLM.Accounts` context.
  """
  alias ClubLM.Accounts

  def unique_user_email, do: "user#{System.unique_integer()}@test.com"
  def valid_user_password, do: "password"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: Faker.Person.En.first_name() <> " " <> Faker.Person.En.last_name(),
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user()

    {:ok, user} = Accounts.update_user_as_admin(user, attrs)

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
