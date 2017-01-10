defmodule Queuex.Mixfile do
  use Mix.Project

  def project do
    [ app: :queuex,
      version: "0.2.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: "Priority Queue",
      source_url: "https://github.com/falood/queuex",
      package: package(),
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp package do
    %{ licenses: ["WTFPL"],
       links: %{"Github" => "https://github.com/falood/queuex"}
     }
  end
end
