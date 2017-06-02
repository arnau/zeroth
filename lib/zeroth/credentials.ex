defmodule Zeroth.Credentials do
  @moduledoc """
  Client credentials. If you come from `Zeroth.Client` you might be interested
  in `Zeroth.Token` as well.

  If you use environment variables you can use `Zeroth.Client.from_env/0`
  which takes care of everything.

  If you want to manage it by yourself, the simplest way is using
  `Zeroth.Credentials.from_list/1`:

      Credentials.from_list([client_id: "x",
                             client_secret: "y",
                             host: URI.parse("https://foo.auth0.com")])

  And then pass that to `Zeroth.Client.from_credentials/1`.
  """

  @enforce_keys [:client_id, :client_secret, :audience]
  @derive [Poison.Encoder]
  defstruct [client_id: nil,
             client_secret: nil,
             grant_type: "client_credentials",
             audience: nil]
  @type t :: %__MODULE__{client_id: String.t,
                         client_secret: String.t,
                         grant_type: String.t,
                         audience: URI.t}

  @doc """
  Composes a Credentials struct from a list.

      iex> alias Zeroth.Credentials
      ...> Credentials.from_list([client_id: "x",
      ...>                        client_secret: "y",
      ...>                        host: URI.parse("https://foo.auth0.com")])
      {:ok, %Zeroth.Credentials{client_id: "x",
                                client_secret: "y",
                                grant_type: "client_credentials",
                                audience: %URI{authority: "foo.auth0.com",
                                               fragment: nil,
                                               host: "foo.auth0.com",
                                               path: "/api/v2/",
                                               port: 443,
                                               query: nil,
                                               scheme: "https",
                                               userinfo: nil}}}
  """
  @spec from_list(list) :: Result.t(String.t, t)
  def from_list(xs) when is_list(xs) do
    {:ok, %__MODULE__{client_id: Keyword.get(xs, :client_id),
                      client_secret: Keyword.get(xs, :client_secret),
                      audience: URI.merge(Keyword.get(xs, :host), "/api/v2/")}}
  rescue
    _ -> {:error, "The host must be an absolute URI: https://example.auth0.com"}
  end
end
