defmodule Zeroth.Log do
  @moduledoc """
  Auth0 Log management. https://auth0.com/docs/api/management/v2#!/Logs
  """

  alias Zeroth.Api
  alias Zeroth.Token
  alias Zeroth.Param
  alias Lonely.Result
  alias URI.Ext, as: URIE

  @path URI.parse("/api/v2/logs")

  @derive [Poison.Encoder]
  defstruct [:client_id,
             :client_name,
             :connection_id,
             :date,
             :description,
             :details,
             :ip,
             :location_info,
             :log_id,
             :scope,
             :type,
             :user_agent,
             :user_id,
             :user_name]

  @type t :: %__MODULE__{client_id: String.t | nil,
                         client_name: String.t | nil,
                         connection_id: String.t | nil,
                         date: DateTime.t | nil,
                         description: String.t | nil,
                         details: map | nil,
                         ip: String.t | nil,
                         location_info: map | nil,
                         log_id: String.t | nil,
                         scope: [String.t] | nil,
                         type: String.t | nil,
                         user_agent: String.t | nil,
                         user_id: String.t | nil,
                         user_name: String.t | nil}

  @doc """
  https://auth0.com/docs/api/management/v2#!/Logs/get_logs

  ## Options

  ### Search by criteria

  * `q`: Search Criteria using Query String Syntax.
  * `page`: The page number. Zero based.
  * `per_page`: The amount of entries per page.
  * `sort`: The field to use for sorting. Use field:order, where order is `1` for ascending and `-1` for descending. For example `date:-1`.
  * `fields`: A comma separated list of fields to include or exclude (depending on `include_fields`) from the result, empty to retrieve all fields.
  * `include_fields`: true if the fields specified are to be included in the result, false otherwise. Defaults to `true`.
  * `include_totals`: true if a query summary must be included in the result, false otherwise. Default `false`.

  ### Search by checkpoint

  * `from`: Log Event Id to start retrieving logs. You can limit the amount of logs using the take parameter.
  * `take`: The total amount of entries to retrieve when using the from parameter.

  ## Examples

      Log.all(api_client)

      Log.all(api_client, q: "date:2017 AND type:seccft")

      Log.all(api_client, per_page: 2, fields: [:client_name, :date, :log_id])
  """
  @spec all(Api.t, list) :: Result.t(any, [t])
  def all(api_client, options \\ []) do
    query = Param.take(options, [:q,
                                 :page,
                                 :per_page,
                                 :sort,
                                 :fields,
                                 :include_fields,
                                 :include_totals,
                                 :from,
                                 :take])
    path = URIE.merge_query(@path, query)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: [%__MODULE__{}])
  end

  @doc """
  https://auth0.com/docs/api/management/v2#!/Logs/get_logs_by_id
  """
  @spec get(String.t, Api.t) :: Result.t(any, t)
  def get(id, api_client) when is_binary(id) do
    path = URIE.merge_path(@path, id)

    api_client
    |> Api.update_endpoint(path)
    |> Api.get(headers: Token.http_header(api_client.credentials),
               as: %__MODULE__{})
  end
end

defimpl Poison.Decoder, for: Zeroth.Log do
  alias Lonely.Result

  def decode(log = %{date: date}, _options) do
    date
    |> DateTime.from_iso8601()
    |> Result.fit()
    |> Result.map(fn {date, _} -> %{log | date: date} end)
    |> Result.map_error(fn _ -> log end)
    |> Result.unwrap()
  end
end
