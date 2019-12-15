defmodule Mix.Tasks.Ecto.Setup.Arango do
  use Mix.Task
  import Mix.EctoAQL

  @shortdoc "Sets up all necessary collections in _systems db for migrations "

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    case create_migrations() do
      {:ok, _, _} ->
        :ok = create_master_document()
        Mix.shell().info("Setup Complete!")

      {:error, 409} ->
        Mix.shell().info("Looks like you're already all set up!")
    end
  end
end
