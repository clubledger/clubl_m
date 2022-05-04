# ClubL M

## Get up and running

0. Optionally install Elixir & Erlang & Node using asdf - see below
0. Optionally change your database name in `dev.exs`
1. Setup the project with `mix setup`
2. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
3. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
4. Do a global search for `SETUP_TODO` and follow the instructions to mold the boilerplate to your brand

## Managing Elixir & Erlang & Node with asdf

We use [asdf](https://asdf-vm.com) for managing tool versions.

The file `.tool-version` tells asdf which versions we use.

Run `asdf install` to install those versions.

BUG - if you get an error like `Getting no such file or directory’, ‘ssl.app’`, then you can do this:

```
asdf uninstall erlang <version>
brew install openssl
asdf plugin-update erlang
ERLANG_OPENSSL_PATH="/opt/homebrew/opt/openssl@3" asdf install erlang <version>
```

## Summary of added functionality

The goal of ClubLM is to give a good starting base for web apps. After creating many web applications we have found that most web apps need:

- User authentication
- Logging user actions for analytics
- Admin functionality to view user activity and suspend users
- Robust emailing system - can email all members or segments of users for marketing purposes
- Users can easily unsubscribe from different types of emails

### In depth list of added functionality

- Uses [Petal Components](https://github.com/petalframework/petal_components)
- Users
  - New fields:
    - `:name, :string`
    - `:avatar, :string`
    - `:last_signed_in_ip, :string`
    - `:last_signed_in_datetime, :utc_datetime`
    - `:is_subscribed_to_marketing_notifications, :boolean, null: false, default: true`
    - `:is_admin, :boolean, null: false, default: false`
    - `:is_suspended, :boolean, null: false, default: false`
    - `:is_deleted, :boolean, null: false, default: false`
  - Notifications
    - A user can have multiple notification subscriptions (eg. marketing updates, comment updates, like updates etc)
    - Users can unsubscribe from any notification subscription - `ClubLM.Accounts.NotificationSubscriptions.unsubscribe_url(user, "marketing_notifications") => http://localhost:4000/unsubscribe/8B5e0rpXQD/marketing_notifications` - this link can be used in emails so users can easily unsubscribe
    - Easy to add new notification types (eg. `user.is_subscribed_to_new_comment_notifications`)
- Admin functionality
  - `user.is_admin = true`
  - can see a list of all users and their info
  - can edit users details
  - can view any users activity on the platform (using the Logs table)
  - can suspend a user (suspended user will be auto-signed out and cannot sign in)
- Menus
  - See `menus.ex`
  - A place to store your menu items to prevent duplication - layouts will use them
- Shared components
  - `<.logo />` - edit this to your logo in `brand.ex`
  - `<.notification />` - shows flash notifications - pairs with `RemoveFlashHook`
  - Layouts
    - `<.navbar />` a simple top header with main menu links and an avatar dropdown for logged in users
    - `<.sidebar_layout />` a full app dashboard layout
    - `<.auth_layout />` used for auth-related pages like register/sign in (has no header - just a logo and auth form)
- Util - list of the primary functions in `/lib/util/util.ex`
  - `Util.email_valid?(email)`
    - Advanced email validation
    - `{:email_checker, "~> 0.1.2"}`
    - helps validating emails by checking their MX records.
  - `Util.blank?(val)`
    - Allows you to check more loosely for boolean values - eg sometimes you want `[]` or `""` to be falsy
    - `{:blankable, "~> 1.0.0"}`
  - `Util.format_money(cents)`
    - Format money values - eg. `CurrencyFormatter.format(654321)` => "$6,543.21"
    - `{:currency_formatter, "~> 0.4"}`
  - `Util.pluralize(string, count)`
    - Help with pluralization - `pluralize("hat", 2) == "hats"`
    - `{:inflex, "~> 2.0.0"}`
- DB module
  - Utility functions related to the database. eg. `DB.last(User) == %User{id: 10, ...}`
  - See `lib/util/db.ex`
- Javascript hooks
  - ResizeTextareaHook - resize textareas while typing
  - BodyScrollLockHook - lock the body while modal open
  - RemoveFlashHook - allows you to close flashes from the server
- Background tasks
  - A module to easily run async code - useful for things like sending emails
  - `ClubLM.BackgroundTask.run(fn -> ...time intensive task... end)`
- HTML emails
  - Includes an email layout with some basic components to build emails with
  - See `lib/clubl_m_web/templates/email/template.html.heex` for the components - or run the server, sign in, then go to `/dev/emails`
  - `ClubLMWeb.Components.EmailHelpers`
- Helper libraries
  - Petal Components - set of HEEX components styled with Tailwind created by us
  - Timex - help deal with time/dates - includes timezone support
  - Faker - fake words for seed and test data
  - Tesla - help with 3rd party APIs
  - Query Builder - easier ecto queries
  - Inflex - help dealing with plurals
  - Currency formatter - 1000 -> $1,000
  - Blankable - see `Util.blank?` above
  - Email checker - see `Util.email_valid?` above

