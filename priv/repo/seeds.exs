# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ClubLM.Repo.insert!(%ClubLM.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ClubLM.Accounts.User
alias ClubLM.Accounts.UserToken
alias ClubLM.Logs.Log
alias ClubLM.Accounts.UserSeeder

if Mix.env() == :dev do
  ClubLM.Repo.delete_all(Log)
  ClubLM.Repo.delete_all(UserToken)
  ClubLM.Repo.delete_all(User)

  UserSeeder.admin()
  UserSeeder.random_users(20)
end
