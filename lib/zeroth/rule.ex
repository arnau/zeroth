defmodule Zeroth.Rule do
  @moduledoc """
  Auth0 Rule management. https://auth0.com/docs/api/management/v2#!/Rules
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias Lonely.Option
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/rules")

  @derive [Poison.Encoder, Poison.Decoder]
  defstruct [:name,
             :id,
             :enabled,
             :script,
             :order,
             :stage]
  @type t :: %__MODULE__{name: String.t,
                         id: String.t,
                         enabled: boolean,
                         script: String.t,
                         order: integer,
                         stage: String.t}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Rules/get_rules
  """
  @spec all(Api.t, list) :: Result.t(any, [t])
  def all(api_client, options \\ []) do
    query = options
            |> Param.take([:enabled,
                           :fields,
                           :include_fields])
    path = URIE.merge_query(@path, query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Rules/get_rules_by_id
  """
  @spec get(String.t, Api.t, list) :: Result.t(any, t)
  def get(id, api_client, options \\ []) when is_binary(id) do
    query = Param.take(options, [:fields, :include_fields])
    path = @path
           |> URIE.merge_path(id)
           |> URIE.merge_query(query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Rules/post_rules

  ## Examples

      Rule.create(%{name: "my-rule",
                    script: "function (user, context, callback) { callback(null, user, context); }",
                    order: 2,
                    enabled: true}, api_client)
  """
  @spec create(map, Api.t) :: Result.t(any, t)
  def create(body, api_client) when is_map(body) do
    body[:name] || {:error, "You must specify the Rule name."}
    body[:script] || {:error, "You must specify the Rule script."}

    api_client
    |> Api.update_endpoint(@path)
    |> Api.post(body, headers: Token.http_header(api_client.credentials),
                      as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Rules/patch_rules_by_id
  """
  @spec update(String.t, map, Api.t) :: Result.t(any, t)
  def update(id, body, api_client) when is_map(body) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.patch(body, headers: Token.http_header(api_client.credentials),
                       as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Rules/delete_rules_by_id
  """
  @spec delete(String.t, Api.t) :: Result.t(any, atom)
  def delete(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end
end
