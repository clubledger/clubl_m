defmodule ClubLM.Repo do
  use Ecto.Repo,
    otp_app: :clubl_m,
    adapter: Ecto.Adapters.Postgres
end
