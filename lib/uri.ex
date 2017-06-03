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

      iex> URI.Ext.merge_query(URI.parse("/foo"), "q=1") |> to_string()
      "/foo?q=1"
  """
  @spec merge_query(URI.t | String.t, map | String.t | nil) :: URI.t
  def merge_query(path, nil), do: URI.parse(path)
  def merge_query(path, query) when is_map(query) do
    path
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(query))
  end
  def merge_query(path, query) when is_binary(query) do
    path
    |> URI.parse()
    |> Map.put(:query, query)
  end

  @doc """
  Merges two paths. Similar to `URI.merge/2` but the first URI can be
  relative.

      iex> URI.Ext.merge_path("foo", "bar") |> to_string()
      "/foo/bar"

      iex> URI.Ext.merge_path(URI.parse("/foo"), "bar") |> to_string()
      "/foo/bar"

      iex> URI.Ext.merge_path(URI.parse("http://localhost/foo"), "bar") |> to_string()
      "http://localhost/foo/bar"
  """
  @spec merge_path(URI.t | String.t, String.t) :: URI.t
  def merge_path(u = %URI{path: a}, b) when is_binary(b) do
    Map.put(u, :path, join_segments([a, b]))
  end
  def merge_path(a, b) when is_binary(a) do
    URI.parse(join_segments([a, b]))
  end

  @doc """
  Joins a list of segments into a path.

      iex> URI.Ext.join_segments(["x", "y"])
      "/x/y"

      iex> URI.Ext.join_segments(["/x", "/y"])
      "/x/y"

      iex> URI.Ext.join_segments(["/x/", "/y/"])
      "/x/y"

      iex> URI.Ext.join_segments(["x//", "y/"])
      "/x/y"
  """
  def join_segments(segments) do
    segments
    |> Enum.map(&String.trim(&1, "/"))
    |> Enum.join("/")
    |> (&("/" <> &1)).()
  end
end
