ExUnit.configure(exclude: :feature)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ClubLM.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, ClubLMWeb.Endpoint.url())
