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
  def filter({:include_fields, value}) when is_boolean(value), do: true
  def filter({:fields, []}), do: false
  def filter({:fields, value}) when is_list(value), do: true
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
end
