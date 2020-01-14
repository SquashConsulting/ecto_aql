# EctoAQL

## Installation

### Step 1:

The package can be installed
by replacing `ecto_sql` with `ecto_aql` in your Phoenix Project's `mix.exs` file:

```elixir
def deps do
  [
    {:ecto_aql, git: "git://github.com/SquashConsulting/ecto_aql.git"}
  ]
end
```

### Step 2:

Inside `<YOUR-PHOENIX-PROJECT>/priv/repo/migrations/.formatter.exs` add `ecto_aql`

```elixir
- import_deps: [:ecto_sql]
+ import_deps: [:ecto_aql]
```

### Step 3:

Inside `<YOUR-PHOENIX-PROJECT>/lib/hopper/repo.ex` replace the default `use` macro with:

```elixir
use EctoAQL.Repo,
  otp_app: :the_name_of_your_app
```

### Step 4:

Run ArangoDB on http://localhost:8529 and create a database.

Inside `<YOUR-PHOENIX-PROJECT>/config/dev.exs` replace the default `Repo` config with:

```elixir
config :your_otp_app, YourApp.Repo,
  pool_size: 10,
  database: "name_of_the_database",
  show_sensitive_data_on_connection_error: true
```

### Step 5:

`cd` into the root of your Phoenix project directory and run:

```bash
$ mix ecto.setup.arango

Setup Complete!
```

This command will create a system collection called `_migrations` in the `_system` db of Arango and will create a `MASTER` migration document that will be used to keep track of the migrated versions of your database.

## Available Commands

To generate migrations run:

```bash
$ mix ecto.gen.migration create_users

* creating priv/repo/migrations/20200114155636_create_users.exs
```

This will create a base migration module with two main functions:

- `up` to migrate the db
- `down` to rollback the db

Inside the file you can use the publicly available functions from `EctoAQL.Repo` module like so:

```elixir
defmodule YourApp.Repo.Migrations.CreateUsers do
  alias Elixir.YourApp.Repo

  def up do
    Repo.create_collection("users", :document)
  end

  def down do
    Repo.drop_collection("users")
  end
end
```

To run the migration run:

```bash
$ mix ecto.migrate # or mix ecto.migrate up

Successfully Migrated 20200114155636_create_users.exs
```

To rollback run:

```bash
$ mix ecto.migrate rollback

Successfully Rolled Back 20200114155636
```
