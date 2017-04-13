defmodule WebTerminal.Mixfile do
  use Mix.Project

  def project do
    [app: :web_terminal,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {WebTerminal.Application, []}]
  end

  defp deps do
    [{:erlexec, git: "https://github.com/noelbk/erlexec.git"},
     {:cowboy, git: "https://github.com/ninenines/cowboy.git", branch: "master"},
     {:poison, "~> 3.1"}]
  end
end
