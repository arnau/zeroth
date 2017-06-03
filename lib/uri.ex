defmodule URI.Ext do
  @moduledoc """
  URI extension. Adds a few helpers to work with URIs.
  """

  @doc """
  Takes a path and a map of query pairs and returns a `URI.t`.

      iex> URI.Ext.merge_query("/foo", %{q: 1, p: 2}) |> to_string()
      "/foo?p=2&q=1"

      iex> URI.Ext.merge_query("/foo", nil) |> to_string()
      "/foo"

      iex> URI.Ext.merge_query(URI.parse("/foo"), %{q: 1}) |> to_string()
      "/foo?q=1"
  """
  def merge_query(path, nil), do: URI.parse(path)
  def merge_query(path, query) when is_map(query) do
    URI.parse(path) |> Map.put(:query, URI.encode_query(query))
  end
end
