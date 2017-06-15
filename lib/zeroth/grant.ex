defmodule Zeroth.Grant do
  @moduledoc """
  Auth0 Grant management. https://auth0.com/docs/api/management/v2#!/Connections
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Lonely.Result
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/grants")

  @derive [Poison.Encoder, Poison.Decoder]
  defstruct [:id,
             :clientID,
             :user_id,
             :audience,
             :scope]

  @type t :: %__MODULE__{id: String.t,
                         clientID: String.t,
                         user_id: String.t,
                         audience: String.t,
                         scope: [String.t]}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Grants/get_grants
  """
  @spec get_by_user_id(String.t, Api.t) :: Result.t(any, [t])
  def get_by_user_id(user_id, api_client) do
    path = URIE.merge_query(@path, %{user_id: user_id})

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Grants/delete_grants_by_id
  """
  @spec delete(String.t, Api.t) :: Result.t(any, atom)
  def delete(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end
end
