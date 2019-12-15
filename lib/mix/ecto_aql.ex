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

  def system_db do
    options = [
      pool_size: 1,
      database: "_system",
      endpoints: "http://localhost:8529"
    ]

    Arangox.start_link(options)
  end
end
