defmodule Zeroth.Token do
  @moduledoc """
  Provides functions to retrieve a token.
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

    client = Zeroth.Client.new(domain, credentials)
    fetch(client)
  """
  # @spec fetch(Client.t, String.t) :: Result.t
  def fetch(client, path \\ "oauth/token") do
    body = client.credentials
           |> Map.from_struct()
           |> Map.put(:audience, to_string(client.credentials.audience))

    client
    |> Api.update_endpoint(path)
    |> Api.post(body)
  end

  #   data = Poison.decode!(response.body)
  #   token = Map.get(data, "access_token")

  #   put(:token, token)
  #   put(:exp, expires_at(token))

  #   token
  # end
end
