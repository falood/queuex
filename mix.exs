defmodule Queuex.Mixfile do
  use Mix.Project

  def project do
    [ app: :queuex,
      version: "0.1.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,
      description: "Priority Queue",
      source_url: "https://github.com/falood/queuex",
      package: package,
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp package do
    %{ licenses: ["BSD 3-Clause"],
       links: %{"Github" => "https://github.com/falood/queuex"}
     }
  end
end
