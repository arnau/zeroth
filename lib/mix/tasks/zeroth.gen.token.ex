defmodule Mix.Tasks.Zeroth.Gen.Token do
  @shortdoc "Generates a token for the given Auth0 client"
  @moduledoc """
  Generates a token for the given Auth0 client.

  In its simplest form, the task uses the values from the environment:
  `AUTH0_HOST`, `AUTH0_CLIENT_ID` and `AUTH0_CLIENT_SECRET`.

      mix zeroth.gen.token

  Alternatively you can provide the three bits of information with flags:

      mix zeroth.gen.token --client-id foo --client-secret bar --host https://foo.auth0.com

  """

  use Mix.Task

  alias Zeroth.HTTPClient
  alias Zeroth.Credentials
  alias Zeroth.Token
  alias Lonely.Result

  @doc false
  def run(argv) do
    argv
    |> OptionParser.parse([strict: [client_id: :string,
                                    client_secret: :string,
                                    host: :string]])
    |> validate_input()
    |> Result.flat_map(&validate_options/1)
    |> Result.flat_map(&HTTPClient.from_list/1)
    |> Result.flat_map(&fetch/1)
    |> Result.map(fn %{token: token} -> Mix.shell.info([:green, token]) end)
    |> Result.map_error(fn
      %{error_description: reason} -> Mix.shell.error(reason)
      error -> Mix.shell.error(inspect(error))
    end)
  end

  def validate_input({opts, _, []}), do: {:ok, opts}
  def validate_input({_, _, invalid}), do: {:error, inspect(invalid)}

  def validate_options(xs) when length(xs) in [0, 3], do: {:ok, xs}
  def validate_options(_), do:
    {:error, "You need to provide no flags or three: --client-id, --client-secret and --host"}

  def fetch(client) do
    HTTPoison.start()
    Token.fetch(client)
  end
end
