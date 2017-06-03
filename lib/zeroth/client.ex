defmodule Zeroth.Client do
  @moduledoc """
  Auth0 Client management. https://auth0.com/docs/api/management/v2#!/Clients
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Lonely.Result

  @path URI.parse("/api/v2/clients")

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
                         mobile: %{android: %{app_package_name: String.t,
                                              sha256_cert_fingerprints: [String.t]} | nil,
                                   ios: %{team_id: String.t,
                                          app_bundle_identifier: String.t} | nil},
                         name: String.t,
                         oidc_conformant: boolean | nil,
                         owners: [String.t] | nil,
                         sso: boolean,
                         sso_disabled: boolean,
                         token_endpoint_auth_method: String.t | nil,
                         jwt_configuration:  %{lifetime_in_seconds: non_neg_integer,
                                               secret_encoded: boolean | nil,
                                                scopes: map | nil,
                                                alg: String.t | nil} | nil,
                         signing_keys: [%{cert: String.t,
                                          pkcs7: String.t,
                                          subject: String.t}],
                         tenant: String.t}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Clients/get_clients
  """
  @spec all(Api.t, list) :: [t]
  def all(api_client, options \\ []) do
    path = URI.Ext.merge_query(@path, options[:query])

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials), as: [%__MODULE__{}])
  end
end
