defmodule Zeroth.User do
  @moduledoc """
  Auth0 User management. https://auth0.com/docs/api/management/v2#!/Users
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias Lonely.Option
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/users")

  @derive [Poison.Encoder, Poison.Decoder]
  defstruct [:email,
             :email_verified,
             :phone_number,
             :phone_verified,
             :user_id,
             :created_at,
             :updated_at,
             :identities,
             :app_metadata,
             :user_metadata,
             :picture,
             :name,
             :nickname,
             :multifactor,
             :last_ip,
             :last_login,
             :logins_count,
             :blocked,
             :given_name,
             :family_name]
  @type t :: %__MODULE__{email: String.t | nil,
                         email_verified: boolean | nil,
                         phone_number: String.t | nil,
                         phone_verified: boolean | nil,
                         user_id: String.t | nil,
                         created_at: DateTime.t |nil,
                         updated_at: DateTime.t | nil,
                         identities: list(String.t) | nil,
                         app_metadata: map | nil,
                         user_metadata: map | nil,
                         picture: String.t | nil,
                         name: String.t | nil,
                         nickname: String.t | nil,
                         multifactor: list(String.t) | nil,
                         last_ip: String.t | nil,
                         last_login: String.t | nil,
                         logins_count: integer | nil,
                         blocked: boolean | nil,
                         given_name: String.t | nil,
                         family_name: String.t | nil}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Users/get_users

  ## Options

  * `q`: Search Criteria using Query String Syntax.
  * `page`: The page number. Zero based.
  * `per_page`: The amount of entries per page.
  * `sort`: The field to use for sorting. Use field:order, where order is `1` for ascending and `-1` for descending. For example `date:-1`.
  * `fields`: A comma separated list of fields to include or exclude (depending on `include_fields`) from the result, empty to retrieve all fields.
  * `include_fields`: true if the fields specified are to be included in the result, false otherwise. Defaults to `true`.
  * `include_totals`: true if a query summary must be included in the result, false otherwise. Default `false`.

  **Note**: If there is no default `sort` field defined the results may be
  inconsistent. E.g. Duplicate records or users that never logged in not
  appearing.

  ## Examples

      User.all(api_client, [q: "identities.connection:'myconnection'",
                            sort: "email:1"])
  """
  @spec all(Api.t, list) :: Result.t(any, [t])
  def all(api_client, options \\ []) do
    query = options
            |> Param.take([:per_page,
                           :page,
                           :include_totals,
                           :sort,
                           :connection,
                           :fields,
                           :include_fields,
                           :q])
            |> Option.map(&Keyword.put(&1, :search_engine, "v2"))
    path = URIE.merge_query(@path, query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Users/get_users_by_id

  ## Options

  * `fields`: List of fields to include or exclude from the result.
  * `include_fields`: If the fields specified are to be included in the result.

  ## Examples

      User.get("foo", api_client)
      User.get("foo", api_client, fields: ["email", "user_id"])
      User.get("foo", api_client, fields: ["email"], include_fields: true)
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
  https://auth0.com/docs/api/management/v2#!/Users/post_users

  You must provide a valid `connection` name for any new user. You will have
  to check what fields are required for the connection type. For example,
  an Auth0 DB requires `email` and `password`.
  """
  @spec create(map, Api.t) :: Result.t(any, t)
  def create(body, api_client) when is_map(body) do
    body[:connection] || {:error, "You must specify a Connection for a new User."}

    api_client
    |> Api.update_endpoint(@path)
    |> Api.post(body, headers: Token.http_header(api_client.credentials),
                      as: %__MODULE__{})
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Users/patch_users_by_id

  `user_metadata` and `app_metadata` fields will be shallow merged instead of
  replaced.

  You must provide the `connection` field when you want to update `email_verified`,
  `phone_verified`, `username` or `password`. And the `client_id` as well if
  you want to update `email` or `phone_number`.

  ## Examples

      User.update(api_client, %{client_id: "xyz",
                                connection: "myconnection",
                                email: "new@example.org",
                                verify_email: true})
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
  https://auth0.com/docs/api/management/v2#!/Users/delete_users_by_id
  """
  @spec delete(String.t, Api.t) :: Result.t(any, atom)
  def delete(id, api_client) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.delete(headers: Token.http_header(api_client.credentials))
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Users/get_enrollments
  """
  @spec enrollments(String.t, Api.t) :: Result.t(any, atom)
  def enrollments(id, api_client) do
    path = URIE.merge_path(@path, "#{id}/enrollments")

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%Zeroth.User.Enrollment{}])
  end
end
