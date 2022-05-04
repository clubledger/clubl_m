defmodule ClubLM.Logs do
  @moduledoc """
  A context file for CRUDing logs
  """

  import Ecto.Query, warn: false
  alias ClubLM.Repo
  alias ClubLM.Logs.Log
  require Logger

  # Logs allow you to keep track of user activity.
  # This helps with both analytics and customer support (easy to look up a user and see what they've done)
  # If you don't want to store logs on your db, you could rewrite this file to send them to a 3rd
  # party service like https://www.datadoghq.com/

  def get(id), do: Repo.get(Log, id)

  def create(attrs \\ %{}) do
    case %Log{}
         |> Log.changeset(attrs)
         |> Repo.insert() do
      {:ok, log} ->
        ClubLMWeb.Endpoint.broadcast("logs", "new-log", log)
        {:ok, log}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def log_sync(action, params, throttle_seconds \\ 0) do
    log_params = log(action, params)

    if throttle_seconds > 0 do
      case DB.where(Log, Map.drop(log_params, [:metadata]))
           |> DB.order_by(id: :desc)
           |> DB.limit(1)
           |> Repo.one() do
        nil ->
          create(log_params)

        last_log ->
          seconds_from_last_entry = Timex.diff(Timex.now(), last_log.inserted_at, :seconds)

          if seconds_from_last_entry > throttle_seconds do
            create(log_params)
          end
      end
    else
      create(log_params)
    end
  end

  def log_async(action, params, throttle_seconds \\ 0) do
    ClubLM.BackgroundTask.run(fn ->
      log_sync(action, params, throttle_seconds)
    end)
  end

  # Catch all, for simple actions
  def log(action, params) do
    target_user_id = if params[:target_user], do: params[:target_user].id, else: params.user.id

    %{
      user_id: params.user.id,
      target_user_id: target_user_id,
      action: action,
      user_role: if(params.user.is_admin, do: "admin", else: "user"),
      metadata: params[:metadata] || %{}
    }
  end

  def exists?(params) do
    Log
    |> QueryBuilder.where(params)
    |> ClubLM.Repo.exists?()
  end

  def get_last_log_of_user(user) do
    ClubLM.Logs.LogQuery.by_user(user.id)
    |> ClubLM.Logs.LogQuery.order_by(:newest)
    |> DB.limit(1)
    |> ClubLM.Repo.one()
  end
end
