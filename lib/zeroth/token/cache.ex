defmodule Zeroth.Token.Cache do
  @moduledoc """
  Agent acting as a cache for a token.
  """

  alias Zeroth.Token

  @doc false
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  @doc false
  def put(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  @doc false
  def get_all do
    Agent.get(__MODULE__, &(&1))
  end

  @doc false
  def fetch() do
    body = %{client_id: "",
             client_secret: "",
             grant_type: "client_credentials",
             audience: "https://foo.auth0.com/api/v2/"}
    response = HTTPoison.post!("https://foo.auth0.com/oauth/token",
                               Poison.encode!(body),
                               [{"Content-Type", "application/json"}])

    data = Poison.decode!(response.body)
    token = Map.get(data, "access_token")

    put(:token, token)
    put(:exp, expires_at(token))

    token
  end

  @doc false
  def expires_at(token) do
    token
    |> String.split(".")
    |> Enum.at(1)
    |> Base.url_decode64!(padding: false)
    |> Poison.decode!()
    |> Map.get("exp")
  end

  @doc false
  def get_token() do
    token = get(:token)

    if is_nil(token) || has_expired() do
      fetch()
    else
      token
    end
  end

  @doc false
  def has_expired do
    DateTime.to_unix(DateTime.utc_now()) < get(:exp)
  end
end
