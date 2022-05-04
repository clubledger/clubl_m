defmodule ClubLM.Accounts.UserSeeder do
  @moduledoc """
  Generates dummy users for the development environment.
  """
  alias ClubLM.Repo
  alias ClubLM.Accounts
  alias ClubLM.Accounts.User

  @password "password"

  def admin(attrs \\ %{}) do
    {:ok, user} =
      Accounts.register_user(
        Map.merge(
          %{
            name: "John Smith",
            email: "admin@test.com",
            password: @password
          },
          attrs
        )
      )

    {:ok, user} = Accounts.toggle_admin(user)

    {:ok, user} =
      User.confirm_changeset(user)
      |> Repo.update()

    user
  end

  def random_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> random_user_attributes()
      |> Accounts.register_user()

    user
  end

  # Use this for quickly inserting large numbers of users
  # We use insert_all to avoid hashing passwords one by one, which is slow
  def random_users(count) do
    now =
      Timex.now()
      |> Timex.to_naive_datetime()
      |> NaiveDateTime.truncate(:second)

    # This is for the password "password"
    password_hashed = "$2b$12$RCMCDT1LBBp1q7yGGqwkhuw9OgEFXOJEViSkXtC9VfRmivUh.Gk4a"

    users_data =
      Enum.map(1..count, fn _ ->
        random_user_attributes()
        |> Map.drop([:password])
        |> Map.merge(%{
          inserted_at: now,
          updated_at: now,
          confirmed_at: Enum.random([now, now, now, nil]),
          hashed_password: password_hashed
        })
      end)

    Repo.insert_all(User, users_data)
  end

  def unique_user_email, do: "user#{System.unique_integer()}@test.com"

  def random_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: Faker.Person.En.first_name() <> " " <> Faker.Person.En.last_name(),
      email: unique_user_email()
    })
  end
end
