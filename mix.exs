defmodule LoggerLogglyBackend.Mixfile do
  use Mix.Project

  def project do
    [app: :logger_loggly_backend,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:httpoison, "~> 0.8.0"}]
  end

  defp description do
    """
      Loggly logger backend
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE" ],
      maintainers: ["Joey Feldberg"],
      licenses: ["MIT"],
      links: %{"Github": "https://github.com/joeyfeldberg/logger_loggly_backend"}
    ]
  end
end
