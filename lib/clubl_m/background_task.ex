defmodule ClubLM.BackgroundTask do
  @moduledoc """
  Run a function in a separate process parallel to the current one. Useful for things that take a bit of time but you want to send a response back quickly.

  ClubLM.BackgroundTask.run(fn ->
    do_some_time_instensive_stuff()
  end)

  """
  def run(f) do
    # Tests were failing when a background task was run. Hence in test mode we just run the function syncronously
    if Application.get_env(:clubl_m, :env) == :test do
      f.()
    else
      # Docs: https://hexdocs.pm/elixir/Task.html#module-dynamically-supervised-tasks
      Task.Supervisor.start_child(__MODULE__, f, restart: :transient)
    end
  end
end
