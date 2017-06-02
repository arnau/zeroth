defmodule Zeroth.Client do
  @moduledoc """
  An agent able to interact with the API.
  """

  alias Zeroth.Client
  alias Zeroth.Credentials
  alias Zeroth.Token

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
      ...> creds = Credentials.from_list([client_id: "x",
      ...>                                client_secret: "y",
      ...>                                host: URI.parse("https://foo.auth0.com")])
      ...> Client.from_credentials(creds)
      %Zeroth.Client{endpoint: %URI{authority: "foo.auth0.com",
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
                                                      grant_type: "client_credentials"}}
  """
  @spec from_credentials(Credentials.t) :: t
  def from_credentials(credentials) do
    %Zeroth.Client{endpoint: URI.merge(credentials.audience, "/"),
                   credentials: credentials}
  end

  @spec from_env() :: t
  def from_env do
    :zeroth
    |> Application.get_all_env()
    |> Credentials.from_list()
    |> Client.from_credentials()
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
    |> Result.flat_map(fn response -> Poison.decode(response.body) end)
  end

  def update_endpoint(client, path) do
    Map.put(client, :endpoint, URI.merge(client.endpoint, path))
  end

  def put_endpoint(client, endpoint) do
    Map.put(client, :endpoint, endpoint)
  end
end
