defmodule ExFunky.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exfunky,
      version: "0.0.1",
      elixir: "~> 1.5",
      description: description(),
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.16.3"}
    ]
  end

  defp description do
    "Fun, funky and functional programming in Elixir."
  end

  defp package() do
    [
      name: "exfunky",
      licenses: ["Apache 2.0"],
      maintainers: ["Iskander Sierra"],
      links: %{"GitHub" => "https://github.com/iskandersierra/exfunky"},
      source_url: "https://github.com/iskandersierra/exfunky",
      homepage_url: "https://github.com/iskandersierra/exfunky"
    ]
  end
end
