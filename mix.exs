defmodule EctoAql.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      deps: deps(),
      app: :ecto_aql,
      elixir: "~> 1.8",
      version: @version,
      start_permanent: Mix.env() == :prod,

      # Hex
      description: "Ecto Arango Query Language database migrations, custom Repo. ",
      package: package(),

      # Docs
      name: "Ecto SQL",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      ecto_dep(),
      {:arangox, "~> 0.4.0"},
      {:velocy, "~> 0.1"}
    ]
  end

  defp ecto_dep do
    if path = System.get_env("ECTO_PATH") do
      {:ecto, path: path}
    else
      {:ecto, github: "elixir-ecto/ecto"}
    end
  end

  defp package do
    [
      maintainers: ["Gurgen Hayrapetyan"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/rasjonell/ecto_aql"},
      files: ~w(.formatter.exs mix.exs README.md lib)
    ]
  end

  defp docs do
    [
      main: "Ecto.AQL",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/ecto_aql",
      source_url: "https://github.com/rasjonell/ecto_aql",
      groups_for_modules: [
        "Adapter specification": [
          Ecto.Adapter.Migration,
          Ecto.Adapter.Structure,
          Ecto.Adapters.SQL.Connection,
          Ecto.Migration.Command,
          Ecto.Migration.Constraint,
          Ecto.Migration.Index,
          Ecto.Migration.Reference,
          Ecto.Migration.Table
        ]
      ]
    ]
  end
end
