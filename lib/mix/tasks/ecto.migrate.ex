defmodule Mix.Tasks.Ecto.Migrate do
  use Mix.Task

  import Mix.EctoAQL

  @shortdoc "Runs Migration/Rollback Functions From Your Migration Modules"

  @aliases [
    d: :dir
  ]

  @switches [
    dir: :string
  ]

  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    case migrated_versions() do
      [nil] ->
        Mix.raise("Arango is not set up. Please run `mix ecto.setup.arango` to proceed")

      _ ->
        migrate(args)
    end
  end

  defp migrate(args) do
    case OptionParser.parse!(args, aliases: @aliases, strict: @switches) do
      {[], []} ->
        up()

      {[dir: "up"], _} ->
        up()

      {_, ["up"]} ->
        up()

      {[dir: "down"], _} ->
        down()

      {_, ["down"]} ->
        down()

      {_, ["rollback"]} ->
        down()

      {_, _} ->
        Mix.raise("Unknown arguments, #{inspect(Enum.join(args, " "))}")
    end
  end

  defp up do
    pending_migrations()
    |> Enum.each(fn file_path ->
      case apply(migration_module(file_path), :up, []) do
        :ok ->
          file_path
          |> timestamp()
          |> update_versions()

          Mix.shell().info("Successfully Migrated #{file_path}")

        _ ->
          Mix.shell().error("Unable To Migrate #{file_path}")
      end
    end)
  end

  defp down do
    [last_migrated_version | _] = versions()

    module =
      last_migrated_version
      |> migration_path()
      |> migration_module()

    case apply(module, :down, []) do
      :ok ->
        # UPDATE ROLLBACK

        Mix.shell().info("Successfully Rolled Back #{last_migrated_version}")

      _ ->
        Mix.shell().error("Unable To Rollback #{last_migrated_version}")
    end
  end

  defp migration_module(path) do
    {{:module, module, _, _}, _} =
      File.cwd!()
      |> Path.join("priv/repo/migrations")
      |> Path.join(path)
      |> Code.eval_file()

    module
  end

  defp versions do
    migrated_versions()
    |> Enum.sort(&(&1 >= &2))
  end

  defp pending_migrations do
    File.cwd!()
    |> Path.join("priv/repo/migrations")
    |> File.ls!()
    |> Enum.filter(&(!String.starts_with?(&1, ".")))
    |> Enum.filter(fn file_path ->
      timestamp(file_path) not in versions()
    end)
    |> Enum.sort(fn path1, path2 ->
      timestamp(path1) <= timestamp(path2)
    end)
  end

  defp timestamp(path) do
    path
    |> String.split("_")
    |> hd()
    |> String.to_integer()
  end

  defp migration_path(version) when not is_binary(version) do
    version
    |> to_string()
    |> migration_path()
  end

  defp migration_path(version) do
    File.cwd!()
    |> Path.join("priv/repo/migrations")
    |> File.ls!()
    |> Enum.find(&String.starts_with?(&1, version))
  end
end
