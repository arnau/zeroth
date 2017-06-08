defmodule Zeroth.Client do
  @moduledoc """
  Auth0 Client management. https://auth0.com/docs/api/management/v2#!/Clients
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/clients")

  @derive [Poison.Encoder, Poison.Decoder]
  defstruct [:allowed_clients,
             :allowed_origins,
             :allowed_logout_urls,
             :addons,
             :app_type,
             :callback_url_template,
             :callbacks,
             :client_id,
             :client_metadata,
             :client_secret,
             :config_route,
             :cross_origin_auth,
             :cross_origin_loc,
             :custom_login_page,
             :custom_login_page_on,
             :custom_login_page_preview,
             :description,
             :form_template,
             :global,
             :grant_types,
             :is_first_party,
             :is_token_endpoint_ip_header_trusted,
             :logo_uri,
             :mobile,
             :ios,
             :name,
             :oidc_conformant,
             :owners,
             :sso,
             :sso_disabled,
             :token_endpoint_auth_method,
             :jwt_configuration,
             :signing_keys,
             :tenant]

  @type t :: %__MODULE__{allowed_clients: [String.t] | nil,
                         allowed_origins: [String.t] | nil,
                         allowed_logout_urls: [String.t] | nil,
                         addons: map,
                         app_type: String.t,
                         callback_url_template: boolean,
                         callbacks: [String.t] | nil,
                         client_id: String.t,
                         client_metadata: map | nil,
                         client_secret: String.t,
                         config_route: any | nil,
                         cross_origin_auth: boolean,
                         cross_origin_loc: String.t | nil,
                         custom_login_page: String.t | nil,
                         custom_login_page_on: boolean,
                         custom_login_page_preview: String.t | nil,
                         description: String.t | nil,
                         form_template: String.t | nil,
                         global: boolean,
                         grant_types: [String.t],
                         is_first_party: boolean,
                         is_token_endpoint_ip_header_trusted: boolean,
                         logo_uri: String.t | nil,
                         mobile:
                           %{android:
                             %{app_package_name: String.t,
                               sha256_cert_fingerprints: [String.t]} | nil,
                             ios: %{team_id: String.t,
                                    app_bundle_identifier: String.t} | nil},
                         name: String.t,
                         oidc_conformant: boolean | nil,
                         owners: [String.t] | nil,
                         sso: boolean,
                         sso_disabled: boolean,
                         token_endpoint_auth_method: String.t | nil,
                         jwt_configuration:
                           %{lifetime_in_seconds: non_neg_integer,
                           secret_encoded: boolean | nil,
                           scopes: map | nil,
                           alg: String.t | nil} | nil,
                         signing_keys: [%{cert: String.t,
                                          pkcs7: String.t,
                                          subject: String.t}],
                         tenant: String.t}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Clients/get_clients

  **Note**: `include_totals` is not supported.
  """
  @spec all(Api.t, list) :: Result.t(any, [t])
  def all(api_client, options \\ []) do
    query = Param.take(options, [:per_page,
                                 :page,
                                 :fields,
                                 :include_fields])
    path = URIE.merge_query(@path, query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Clients/get_clients_by_id

  ## Options

  * `fields`: List of fields to include or exclude from the result.
  * `include_fields`: If the fields specified are to be included in the result.

  ## Examples

      Client.get("foo", api_client)
      Client.get("foo", api_client, fields: ["name", "callbacks"])
      Client.get("foo", api_client, fields: ["name"], include_fields: false)
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
  https://auth0.com/docs/api/management/v2#!/Clients/post_clients
  """
  @spec create(t, Api.t) :: Result.t(any, t)
  def create(body = %__MODULE__{}, api_client) do
    body = Param.from_struct(body)
    body[:name] || {:error, "You must specify a name for a new Client."}

    api_client
    |> Api.update_endpoint(@path)
    |> Api.post(body, headers: Token.http_header(api_client.credentials),
                      as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Clients/patch_clients_by_id
  """
  @spec update(String.t, t, Api.t) :: Result.t(any, t)
  def update(id, body = %__MODULE__{}, api_client) do
    path = URIE.merge_path(@path, id)
    body = Param.from_struct(body)

    api_client
    |> Api.update_endpoint(path)
    |> Api.patch(body, headers: Token.http_header(api_client.credentials),
                       as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Clients/delete_clients_by_id
  """
  @spec delete(String.t, Api.t) :: Result.t(any, atom)
  def delete(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Clients/post_rotate_secret
  """
  @spec rotate_secret(String.t, Api.t) :: Result.t(any, t)
  def rotate_secret(id, api_client) do
    path = @path
           |> URIE.merge_path(id)
           |> URIE.merge_path("rotate-secret")

    api_client
    |> Api.update_endpoint(path)
    |> Api.post(%{}, headers: Token.http_header(api_client.credentials),
                     as: %__MODULE__{})
  end
end
