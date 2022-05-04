defmodule ClubLM.Email do
  @moduledoc """
  Houses functions that generate Swoosh email structs.
  An Swoosh email struct can be delivered by a Swoosh mailer (see mailer.ex & user_notifier.ex). Eg:

      ClubLM.Email.confirm_register_email(user.email, url)
      |> ClubLM.Mailer.deliver()
  """

  use Phoenix.Swoosh,
    view: ClubLMWeb.EmailView,
    layout: {ClubLMWeb.EmailView, "email_layout.html"}

  def template(email) do
    base_email()
    |> to(email)
    |> subject("Template for showing how to do headings, buttons etc in emails")
    |> render_body("template.html")
    |> premail()
  end

  def confirm_register_email(email, url) do
    base_email()
    |> to(email)
    |> subject("Confirm instructions")
    |> render_body("confirm_register_email.html", %{url: url})
    |> premail()
  end

  def reset_password(email, url) do
    base_email()
    |> to(email)
    |> subject("Reset password")
    |> render_body("reset_password.html", %{url: url})
    |> premail()
  end

  def change_email(email, url) do
    base_email()
    |> to(email)
    |> subject("Change email")
    |> render_body("change_email.html", %{url: url})
    |> premail()
  end

  # For when you don't need any HTML and just want to send text
  def text_only_email(to_email, subject, body, cc \\ []) do
    new()
    |> to(to_email)
    |> from({from_name(), from_email()})
    |> subject(subject)
    |> text_body(body)
    |> cc(cc)
  end

  defp base_email(opts \\ []) do
    {unsubscribe_url, _opts} = Keyword.pop(opts, :unsubscribe_url)

    new()
    |> from({from_name(), from_email()})
    |> assign(:unsubscribe_url, unsubscribe_url)
  end

  # Inlines your CSS and adds a text option (email clients prefer this)
  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end

  defp from_name do
    Application.get_env(:clubl_m, :mailer_default_from_name)
  end

  defp from_email do
    Application.get_env(:clubl_m, :mailer_default_from_email)
  end

  # Use this when you want to have different types of emails a user can sub/unsub to.
  # User field must begin with "is_subscribed_to_"
  # Eg:  user.is_subscribed_to_comment_replies
  # base_email(unsubscribe_url: unsub_url(comment_owner, "comment_replies"))
  defp get_unsubscribe_url(user, email_kind) do
    ClubLM.Accounts.NotificationSubscriptions.unsubscribe_url(user, email_kind)
  end
end
