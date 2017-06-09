defmodule Zeroth.UserBlock do
  @moduledoc """
  Auth0 User Block management. https://auth0.com/docs/api/management/v2#!/User_Blocks
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias Lonely.Option
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/user-blocks")

  @type t :: %{blocked_for: list(record)}
  @type record :: %{identifier: String.t, ip: String.t}

  @doc """
  https://auth0.com/docs/api/management/v2#!/User_Blocks/get_user_blocks

  ## Examples

      UserBlock.get_by("john.doe@example.org", api_client)
  """
  @spec get_by(String.t, Api.t) :: Result.t(any, t)
  def get_by(id, api_client) do
    path = URIE.merge_query(@path, %{identifier: id})

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials))
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/User_Blocks/get_user_blocks_by_id

  ## Examples

      UserBlock.get(""auth0|593a345f568d8435eae33a8d"", api_client)
  """
  @spec get(String.t, Api.t) :: Result.t(any, t)
  def get(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials))
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/User_Blocks/delete_user_blocks
  """
  @spec unblock_by(String.t, Api.t) :: Result.t(any, atom)
  def unblock_by(id, api_client) do
    path = URIE.merge_query(@path, %{identifier: id})

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/User_Blocks/delete_user_blocks_by_id
  """
  @spec unblock(String.t, Api.t) :: Result.t(any, atom)
  def unblock(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end
end
