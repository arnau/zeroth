defmodule Zeroth.Client do
  @moduledoc """
  An agent able to interact with the API.

  The fastest way to create a client is to set the environment variables
  `AUTH0_HOST`, `AUTH0_CLIENT_ID` and `AUTH0_CLIENT_SECRET` and use
  `Client.from_env/0`. If you prefer composing it yourself, check
  `Client.from_credentials/1` out.
  """

  alias Zeroth.Client
  alias Zeroth.Credentials
  alias Zeroth.Token
  alias Lonely.Result

  @enforce_keys [:endpoint, :credentials]
  defstruct [:endpoint,
             :credentials,
             :connection]
  @type credentials :: Credentials.t | Token.t
  @type t :: %Client{endpoint: URI.t,
                     credentials: Credentials.t | Token.t,
                     connection: String.t | nil}

  @doc """
  Composes a basic `%Client{}` from `%Credentials{}`.

      iex> alias Zeroth.Client
      ...> alias Zeroth.Credentials
      ...> {:ok, creds} = Credentials.from_list([client_id: "x",
      ...>                                       client_secret: "y",
      ...>                                       host: URI.parse("https://foo.auth0.com")])
      ...> Client.from_credentials(creds)
      {:ok, %Zeroth.Client{endpoint: %URI{authority: "foo.auth0.com",
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
    {:ok, %Zeroth.Client{endpoint: URI.merge(credentials.audience, "/"),
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
end

defimpl Zeroth.Api, for: Zeroth.Client do
  alias Lonely.Result

  def get(client) do
    client
  end

  def post(client, body, headers \\ %{}) do
    client.endpoint
    |> HTTPoison.post(Poison.encode!(body),
                      %{"Content-Type" => "application/json"}
                      |> Map.merge(headers)
                      |> Map.to_list())
    |> Result.flat_map(&parse_response/1)
  end

  def parse_response(%{status_code: 200, body: body}) do
    Poison.decode(body)
  end

  def parse_response(response) do
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
