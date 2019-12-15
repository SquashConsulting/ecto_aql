defmodule Mix.EctoAQL do
  @moduledoc false

  def priv_repo_path(repo) do
    app = Keyword.fetch!(repo.config(), :otp_app)
    Path.join(Mix.Project.deps_paths()[app] || File.cwd!(), "priv/repo")
  end

  def timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  def pad(i) when i < 10, do: <<?0, ?0 + i>>
  def pad(i), do: to_string(i)

  def create_migrations do
    {:ok, conn} = system_db()

    case Arangox.post(conn, "/_api/collection", %{
           type: 2,
           isSystem: true,
           name: "_migrations"
         }) do
      {:ok, _, _} -> :ok
      {:error, %{status: status}} -> {:error, status}
    end
  end

  def create_master_document do
    {:ok, conn} = system_db()

    {:ok, _, _} =
      Arangox.post(
        conn,
        "/_api/document/_migrations",
        %{_key: "MASTER", migrations: []}
      )
  end

  def migrated_versions do
    {:ok, conn} = system_db()

    {:ok, versions} =
      query(conn, """
        RETURN DOCUMENT("_migrations/MASTER").migrations
      """)

    versions
  end

  def update_versions(version) when is_binary(version),
    do: update_versions(String.to_integer(version))

  def update_versions(version) do
    {:ok, conn} = system_db()

    new_versions = [version | migrated_versions()]

    {:ok, _, _} =
      Arangox.patch(
        conn,
        "/_api/document/_migrations/MASTER",
        %{migrations: new_versions}
      )

    new_versions
  end

  defp query(conn, query_string) do
    Arangox.transaction(conn, fn cursor ->
      cursor
      |> Arangox.cursor(query_string)
      |> Enum.reduce([], fn resp, acc ->
        acc ++ resp.body["result"]
      end)
      |> List.flatten()
    end)
  end

  defp system_db do
    options = [
      pool_size: 1,
      database: "_system",
      endpoints: "http://localhost:8529"
    ]

    Arangox.start_link(options)
  end
end
