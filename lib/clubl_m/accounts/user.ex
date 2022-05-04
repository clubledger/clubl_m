defmodule ClubLM.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias ClubLM.Accounts
  use QueryBuilder

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :naive_datetime
    field :is_admin, :boolean, default: false
    field :avatar, :string
    field :last_signed_in_ip, :string
    field :last_signed_in_datetime, :utc_datetime
    field :is_subscribed_to_marketing_notifications, :boolean, default: true
    field :is_suspended, :boolean, default: false
    field :is_deleted, :boolean, default: false
    field :is_onboarded, :boolean, default: false

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_email()
    |> validate_name()
    |> validate_password(opts)
  end

  defp validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> update_change(:name, &Util.trim/1)
    |> validate_length(:name, min: 1, max: 160)
  end

  defp validate_email(changeset) do
    changeset
    |> update_change(:email, &Util.trim/1)
    |> validate_required([:email])
    |> validate_change(:email, fn :email, email ->
      if Util.email_valid?(email), do: [], else: [email: "is invalid"]
    end)
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, ClubLM.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc "For when a user updates their email. This will run before a validation email is sent"
  def new_email_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> validate_change(:email, fn :email, email ->
      if Accounts.get_user_by_email(email), do: [email: "is taken"], else: []
    end)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%ClubLM.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc "A changeset for admins changing other users. This should include most user fields."
  def admin_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :avatar,
      :is_subscribed_to_marketing_notifications,
      :is_admin,
      :is_suspended,
      :is_deleted,
      :is_onboarded
    ])
    |> validate_email()
    |> validate_name()
  end

  @doc "A changeset for users changing their details. Keep this limited to what a user can change about themselves."
  def profile_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :name,
      :avatar,
      :is_subscribed_to_marketing_notifications,
      :is_onboarded
    ])
    |> validate_name()
  end

  def last_signed_in_changeset(user, ip) do
    user
    |> cast(%{}, [])
    |> change(%{
      last_signed_in_ip: ip,
      last_signed_in_datetime: DateTime.utc_now() |> DateTime.truncate(:second)
    })
  end

  def change_admin_changeset(user) do
    cast(user, %{is_admin: !user.is_admin}, [:is_admin])
  end
end
