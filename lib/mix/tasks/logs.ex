defmodule Mix.Tasks.Zeroth.Logs do
  @shortdoc "Prints logs from Auth0"
  @moduledoc """
  Prints logs from Auth0.

      mix zeroth.logs

  """

  use Mix.Task

  alias Zeroth.HTTPClient
  alias Zeroth.Token
  alias Zeroth.Log
  alias Lonely.Result

  @doc false
  def run(argv) do
    api_client = argv
                 |> OptionParser.parse([strict: [client_id: :string,
                                                 client_secret: :string,
                                                 host: :string]])
                 |> validate_input()
                 |> Result.flat_map(&validate_options/1)
                 |> Result.flat_map(&HTTPClient.from_list/1)

    HTTPoison.start()

    with {:ok, api_client} <- api_client,
         {:ok, token} <- Token.fetch(api_client),
         api_client = HTTPClient.with_token(api_client, token) do
      api_client
      |> Log.all()
      |> Result.map(&Scribe.print(&1, style: Scribe.Style.Psql, width: 200,
                                      data: [{"Date", fn (x) ->
                                              DateTime.to_iso8601(x.date) end},
                                             {"Type", :type},
                                             {"ID", :log_id},
                                             {"IP", :ip},
                                             {"User ID", :user_id},
                                             {"User", :user_name}]))
    else
      {:error, %{error_description: reason}} ->
        Mix.shell.error(reason)

      error ->
        Mix.shell.error(inspect(error))
    end
  end

  def validate_input({opts, _, []}), do: {:ok, opts}
  def validate_input({_, _, invalid}), do: {:error, invalid}

  def validate_options(xs) when length(xs) in [0, 3], do: {:ok, xs}
  def validate_options(_), do:
    {:error, "You need to provide no flags or three: --client-id, --client-secret and --host"}
end
