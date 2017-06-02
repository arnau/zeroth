defmodule Dotenv do
  @moduledoc false

  @doc false
  def load(filename \\ ".env") do
    filename
    |> File.read()
  end
end
