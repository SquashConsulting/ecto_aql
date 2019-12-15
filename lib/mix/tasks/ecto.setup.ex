defmodule Mix.Tasks.Ecto.Setup do
  use Mix.Task

  import Mix.Ecto
  import Mix.EctoAQL, only: [system_db: 0]

  @shortdoc "Sets up all necessary collections in _systems db for migrations "

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    {:ok, conn} = system_db()

    case Arangox.create_collection(conn, "/_api/collection", %{
           # collection
           type: 2,
           name: "Locations"
         }) do
      {:ok, _, _} -> Mix.shell().info("Setup Complete!")
      {:error, error} -> Mix.shell().error("ERROR: #{inspect(error)}")
    end
  end
end
