defmodule Zeroth.ClientGrant do
  @moduledoc """
  Auth0 Client Grant management. https://auth0.com/docs/api/management/v2#!/Client_Grants
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/client-grants")

  @derive [Poison.Encoder, Poison.Decoder]
  defstruct [:id,
             :client_id,
             :audience,
             :scope]
  @type t :: %__MODULE__{id: String.t,
                         client_id: String.t,
                         audience: String.t,
                         scope: [String.t]}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Client_Grants/get_client_grants
  """
  @spec all(Api.t, list) :: Result.t(any, [t])
  def all(api_client, options \\ []) do
    query = options
            |> Param.take([:audience])
    path = URIE.merge_query(@path, query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Client_Grants/post_client_grants
  """
  @spec create(map, Api.t) :: Result.t(any, t)
  def create(body, api_client) when is_map(body) do
    api_client
    |> Api.update_endpoint(@path)
    |> Api.post(body, headers: Token.http_header(api_client.credentials),
                      as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Client_Grants/patch_client_grants_by_id
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
  https://auth0.com/docs/api/management/v2#!/Client_Grants/delete_client_grants_by_id
  """
  @spec delete(String.t, Api.t) :: Result.t(any, atom)
  def delete(id, api_client) when is_binary(id) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end
end
