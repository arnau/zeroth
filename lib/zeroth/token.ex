defmodule Zeroth.Token do
  @moduledoc """
  Provides functions to handle a token.
  """

  alias Zeroth.Api
  alias Lonely.Result

  @enforce_keys [:token, :expiration_time]
  defstruct [:token, :expiration_time, :scope, :type]
  @type t :: %__MODULE__{token: String.t,
                         expiration_time: non_neg_integer,
                         scope: [String.t] | nil,
                         type: String.t | nil}

  @doc """
    Fetches a new token from the API.

        client = Zeroth.HTTPClient.new(domain, credentials)
        fetch(client)
  """
  @spec fetch(Api.t, String.t) :: Result.t(any, Token.t)
  def fetch(client, path \\ "oauth/token") do
    body = client.credentials
           |> Map.from_struct()
           |> Map.put(:audience, to_string(client.credentials.audience))

    client
    |> Api.update_endpoint(path)
    |> Api.post(body)
    |> Result.map(&decode/1)
  end

  @spec decode(map) :: Token.t
  defp decode(%{"access_token" => token,
                "scope" => scope,
                "token_type" => type}) do
    %__MODULE__{token: token,
                expiration_time: expires_at(token),
                scope: String.split(scope),
                type: type}
  end

  @doc """
  Checks if a token is valid based on its expiration time.

      iex> alias Zeroth.Token
      ...> exp = DateTime.to_unix(DateTime.utc_now()) + 86400
      ...> Token.is_valid(%Token{token: "t", expiration_time: exp})
      true

      iex> alias Zeroth.Token
      ...> exp = DateTime.to_unix(DateTime.utc_now()) - 86400
      ...> Token.is_valid(%Token{token: "t", expiration_time: exp})
      false
  """
  @spec is_valid(Token.t) :: boolean
  def is_valid(%__MODULE__{expiration_time: exp}) do
    DateTime.to_unix(DateTime.utc_now()) < exp
  end

  @doc false
  @spec expires_at(String.t) :: non_neg_integer
  def expires_at(token) do
    token
    |> String.split(".")
    |> Enum.at(1)
    |> Base.url_decode64!(padding: false)
    |> Poison.decode!()
    |> Map.get("exp")
  end
end
