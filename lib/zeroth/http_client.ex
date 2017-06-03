defmodule Zeroth.HTTPClient do
  @moduledoc """
  An agent able to interact with the API.

  The fastest way to create a client is to set the environment variables
  `AUTH0_HOST`, `AUTH0_CLIENT_ID` and `AUTH0_CLIENT_SECRET` and use
  `HTTPClient.from_env/0`. If you prefer composing it yourself, check
  `HTTPClient.from_credentials/1` out.
  """

  alias Zeroth.HTTPClient
  alias Zeroth.Credentials
  alias Zeroth.Token
  alias Lonely.Result

  @enforce_keys [:endpoint, :credentials]
  defstruct [:endpoint,
             :credentials,
             :connection]
  @type credentials :: Credentials.t | Token.t
  @type t :: %__MODULE__{endpoint: URI.t,
                         credentials: Credentials.t | Token.t,
                         connection: String.t | nil}

  @doc """
  Composes a basic `%HTTPClient{}` from `%Credentials{}`.

      iex> alias Zeroth.HTTPClient
      ...> alias Zeroth.Credentials
      ...> {:ok, creds} = Credentials.from_list([client_id: "x",
      ...>                                       client_secret: "y",
      ...>                                       host: URI.parse("https://foo.auth0.com")])
      ...> HTTPClient.from_credentials(creds)
      {:ok, %Zeroth.HTTPClient{endpoint: %URI{authority: "foo.auth0.com",
                                              host: "foo.auth0.com",
                                              path: "/",
                                              port: 443,
                                              scheme: "https"},
                               credentials: %Zeroth.Credentials{audience: %URI{authority: "foo.auth0.com",
                                                                               host: "foo.auth0.com",
                                                                               path: "/api/v2/",
                                                                               port: 443,
                                                                               scheme: "https"},
                                                                client_id: "x",
                                                                client_secret: "y",
                                                                grant_type: "client_credentials"}}}
  """
  @spec from_credentials(Credentials.t) :: Result.t(String.t, t)
  def from_credentials(credentials) do
    {:ok, %Zeroth.HTTPClient{endpoint: URI.merge(credentials.audience, "/"),
                             credentials: credentials}}
  rescue
    _ -> {:error, "The audience must be an absolute URI: https://example.auth0.com"}
  end

  @doc """
  Grabs the credentials from the environment and generates a result with a
  client or an error.
  """
  @spec from_env() :: Result.t(String.t, t)
  def from_env do
    :zeroth
    |> Application.get_all_env()
    |> Credentials.from_list()
    |> Result.flat_map(&from_credentials/1)
  end

  @spec from_list(list) :: Result.t(String.t, t)
  def from_list([]), do: from_env()
  def from_list(xs) do
    xs
    |> Credentials.from_list()
    |> Result.flat_map(&from_credentials/1)
  end

  @doc """
  Use the given token as the client credentials.

      iex> alias Zeroth.HTTPClient
      ...> alias Zeroth.Token
      ...> {:ok, client} = HTTPClient.from_list(host: "https://foo.auth0.com",
      ...>                                      client_id: "x",
      ...>                                      client_secret: "y")
      ...> token = %Token{token: "x", scope: [], expiration_time: 1}
      ...> %{credentials: creds} = HTTPClient.with_token(client, token)
      ...> creds == token
      true
  """
  @spec with_token(t, Token.t) :: t
  def with_token(client = %HTTPClient{}, token = %Token{}) do
    %{client | credentials: token}
  end
end

defimpl Zeroth.Api, for: Zeroth.HTTPClient do
  alias Lonely.Result
  alias Lonely.Option

  def get(client, options \\ []) do
    {headers, options} = Keyword.pop(options, :headers)

    client.endpoint
    |> HTTPoison.get(Option.with_default(headers, %{}))
    |> Result.flat_map(&parse_response(&1, options))
  end

  def post(client, body, options \\ []) do
    {headers, options} = Keyword.pop(options, :headers)

    client.endpoint
    |> HTTPoison.post(Poison.encode!(body),
                      %{"Content-Type" => "application/json"}
                      |> Map.merge(Option.with_default(headers, %{}))
                      |> Map.to_list())
    |> Result.flat_map(&parse_response(&1, options))
  end

  def patch(client, body, options \\ []) do
    {headers, options} = Keyword.pop(options, :headers)

    client.endpoint
    |> HTTPoison.patch(Poison.encode!(body),
                       %{"Content-Type" => "application/json"}
                       |> Map.merge(Option.with_default(headers, %{}))
                       |> Map.to_list())
    |> Result.flat_map(&parse_response(&1, options))
  end

  def delete(client, options \\ []) do
    headers = Keyword.get(options, :headers)

    client.endpoint
    |> HTTPoison.delete(Option.with_default(headers, %{}))
    |> Result.flat_map(&parse_response/1)
  end

  def parse_response(%{status_code: 204}), do: {:ok, :deleted}

  def parse_response(%{status_code: code, body: body}, options)
    when code in [200, 201] do
    Poison.decode(body, options)
  end

  def parse_response(response, _) do
    response.body
    |> Poison.decode(keys: :atoms)
    |> Result.map(&Map.put(&1, :status_code, response.status_code))
    |> Result.flat_map(fn reason -> {:error, reason} end)
  end

  def update_endpoint(client, path) do
    Map.put(client, :endpoint, URI.merge(client.endpoint, path))
  end

  def put_endpoint(client, endpoint) do
    Map.put(client, :endpoint, endpoint)
  end
end
