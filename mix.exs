defmodule Zeroth.Mixfile do
  use Mix.Project

  def project do
    [app: :zeroth,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [remove_defaults: [:unknown]],
     aliases: aliases(),

     # Package
     package: [files: ["config", "lib", "mix.exs", "README.md", "LICENSE"],
               maintainers: ["Arnau Siches"],
               licenses: ["MIT"],
               links: %{"GitHub" => "https://github.com/arnau/zeroth"}],

     # Docs
     name: "Zeroth",
     source_url: "https://github.com/arnau/zeroth",
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.detail": :test,
                         "coveralls.post": :test,
                         "coveralls.html": :test],
     docs: [main: "Zeroth",
            extras: ["README.md"]]]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
     {:excoveralls, "~> 0.6", only: :test},
     {:ex_doc, "~> 0.14", only: [:dev], runtime: false},
     {:httpoison, "~> 0.11"},
     {:poison, "~> 3.1"},
     {:lonely, "~> 0.3"},
     {:scribe, "~> 0.4.0"}]
  end

  defp aliases do
    [check: ["dialyzer", "credo --strict"]]
  end
end
