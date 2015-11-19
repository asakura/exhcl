defmodule Exhcl.Mixfile do
  use Mix.Project

  @version "0.2.1"

  def project do
    [app: :exhcl,
     version: @version,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,

     # Hex
     description: description,
     package: package,

     # Docs
     name: "ExHCL",
     docs: [extras: ["README.md", "CHANGELOG.md"],
            source_ref: "v#{@version}", main: "Exhcl",
            source_url: "https://github.com/asakura/exhcl"]]
  end

  defp description do
    "Configuration language inspired by HCL"
  end

  defp package do
    [maintainers: ["Nikolai Sevostjanov"],
     licenses: ["The MIT License"],
     links: %{"GitHub" => "https://github.com/asakura/exhcl"},
     files: ~w(mix.exs README.md lib src)]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.10", only: :docs},
     {:earmark, "~> 0.1", only: :docs},
     {:inch_ex, only: :docs}]
  end
end
