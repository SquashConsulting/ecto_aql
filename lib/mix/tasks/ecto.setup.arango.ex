defmodule Mix.Tasks.Ecto.Setup.Arango do
  use Mix.Task
  import Mix.EctoAQL, only: [system_db: 0]

  @shortdoc "Sets up all necessary collections in _systems db for migrations "

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    {:ok, conn} = system_db()

    case Arangox.post(conn, "/_api/collection", %{
           type: 2,
           name: "migrations"
         }) do
      {:ok, _, _} -> Mix.shell().info("Setup Complete!")
      {:error, %{status: 409}} -> Mix.shell().info("Looks like you're already all set up!")
      {:error, error} -> Mix.shell().error("Something is not right 🤔, #{inspect(error)}")
    end
  end
end
