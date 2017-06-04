defmodule Zeroth.Param do
  @moduledoc """
  Functions to process API params.
  """

  @doc """
  Takes the params matching the given keys and with the right value.

      iex> Zeroth.Param.take([fields: []], [:fields])
      nil

      iex> Zeroth.Param.take([fields: ["name"]], [:fields])
      %{fields: "name"}
  """
  @spec take(keyword, list) :: map | nil
  def take(params, keys) do
    res = params
    |> Keyword.take(keys)
    |> Enum.filter_map(&filter/1, &mapper/1)
    |> Enum.reduce(%{}, fn ({k, v}, acc) -> Map.put(acc, k, v) end)

    if Enum.empty?(res), do: nil, else: res
  end

  @doc """
  Filters out params of the wrong type.

      iex> Zeroth.Param.filter({:include_fields, true})
      true

      iex> Zeroth.Param.filter({:include_fields, nil})
      false

      iex> Zeroth.Param.filter({:fields, nil})
      false

      iex> Zeroth.Param.filter({:fields, []})
      false

      iex> Zeroth.Param.filter({:fields, ["name"]})
      true
  """
  def filter({:q, value}), do: true
  def filter({:page, value}) when is_integer(value), do: true
  def filter({:per_page, value}) when is_integer(value), do: true
  def filter({:sort, value}) when is_binary(value), do: true
  def filter({:fields, []}), do: false
  def filter({:fields, value}) when is_list(value), do: true
  def filter({:include_fields, value}) when is_boolean(value), do: true
  def filter({:include_totals, value}) when is_boolean(value), do: true
  def filter({_, _}), do: false

  @doc """
  Maps a param to its serialised form.

      iex> Zeroth.Param.mapper({:fields, ["name"]})
      {:fields, "name"}

      iex> Zeroth.Param.mapper({:fields, ["name", "jwt_configuration"]})
      {:fields, "name,jwt_configuration"}
  """
  def mapper({:fields, xs}), do: {:fields, Enum.join(xs, ",")}
  def mapper(param), do: param

  @doc """
  Cleans a struct from nil to prepare it to be serialised to JSON.

      iex> alias Zeroth.Client
      ...> alias Zeroth.Param
      ...> %Client{name: "Foo"} |> Param.from_struct()
      %{name: "Foo"}
  """
  def from_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.to_list()
    |> Enum.reduce(%{}, &from_struct_reducer/2)
  end

  defp from_struct_reducer({_, v}, acc) when is_nil(v), do: acc
  defp from_struct_reducer({k, v}, acc), do: Map.put(acc, k, v)
end
