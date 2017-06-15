defmodule Zeroth.Connection do
  @moduledoc """
  Auth0 Connection management. https://auth0.com/docs/api/management/v2#!/Connections
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias Lonely.Option
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/connections")

  @derive [Poison.Encoder, Poison.Decoder]
  defstruct [:name,
             :id,
             :options,
             :strategy,
             :realms,
             :enabled_clients]
  @type t :: %__MODULE__{name: String.t,
                         id: String.t,
                         options: map,
                         strategy: String.t,
                         realms: list(String.t),
                         enabled_clients: [String.t]}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Connections/get_connections
  """
  @spec all(Api.t, list) :: Result.t(any, [t])
  def all(api_client, options \\ []) do
    query = options
            |> Param.take([:per_page,
                           :page,
                           :strategy,
                           :name,
                           :fields,
                           :include_fields])
    path = URIE.merge_query(@path, query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Connections/get_connections_by_id
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
  https://auth0.com/docs/api/management/v2#!/Connections/post_connections
  """
  def create(body, api_client) when is_map(body) do
    body[:name] || {:error, "You must specify the Connection name."}
    is_strategy(body[:strategy]) || {:error, "You must specify a valid Connection strategy."}

    api_client
    |> Api.update_endpoint(@path)
    |> Api.post(body, headers: Token.http_header(api_client.credentials),
                      as: %__MODULE__{})
  end

  @doc """
      iex> Zeroth.Connection.is_strategy("github")
      true

      iex> Zeroth.Connection.is_strategy(nil)
      false
  """
  @spec is_strategy(String.t | nil) :: boolean
  def is_strategy(strategy) do
    strategy in ~w(ad adfs amazon dropbox bitbucket
                   aol auth0-adldap auth0-oidc auth0
                   baidu bitly box custom dwolla email
                   evernote-sandbox evernote exact facebook
                   fitbit flickr github google-apps google-oauth2
                   guardian instagram ip linkedin miicard oauth1
                   oauth2 office365 paypal paypal-sandbox pingfederate
                   planningcenter renren salesforce-community
                   salesforce-sandbox salesforce samlp sharepoint
                   shopify sms soundcloud thecity-sandbox thecity
                   thirtysevensignals twitter untappd vkontakte waad
                   weibo windowslive wordpress yahoo yammer yandex)
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Connections/patch_connections_by_id
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
  https://auth0.com/docs/api/management/v2#!/Connections/delete_connections_by_id
  """
  @spec delete(String.t, Api.t) :: Result.t(any, atom)
  def delete(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Connections/delete_users_by_email
  """
  @spec delete_user(String.t, String.t, Api.t) :: Result.t(any, atom)
  def delete_user(id, email, api_client) do
    path = @path
           |> URIE.merge_path("#{id}/users")
           |> URIE.merge_query(%{email: email})

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end
end
