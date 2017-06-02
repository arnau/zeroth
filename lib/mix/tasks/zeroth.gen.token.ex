defmodule Mix.Tasks.Zeroth.Gen.Token do
  @shortdoc "Generates a token for the given Auth0 client"
  @moduledoc """
  Generates a token for the given Auth0 client.

  In its simplest form, the task uses the values from the environment:
  `AUTH0_HOST`, `AUTH0_CLIENT_ID` and `AUTH0_CLIENT_SECRET`.

      mix zeroth.gen.token
  """

  use Mix.Task

  alias Zeroth.Client
  alias Zeroth.Credentials
  alias Zeroth.Token

  def run(argv) do
    # {opts, _args, _invalid} =
    #   OptionParser.parse(argv, [switches: [owner: :string]])
    HTTPoison.start()
    client = Client.from_env()
    token = Token.fetch(client)

    Mix.shell.info([:green, inspect(token)])
  end
end
