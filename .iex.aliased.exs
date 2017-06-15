alias Zeroth.HTTPClient
alias Zeroth.Token
alias Zeroth.Client
alias Zeroth.Log
alias Zeroth.User
alias Zeroth.UserBlock
alias Zeroth.Rule
alias Lonely.Result


api_client =
HTTPClient.from_env()
|> Result.flat_map(fn api_client ->
  with {:ok, token} <- Token.fetch(api_client) do
    {:ok, [api_client, token]}
  else
    e -> e
  end
end)
|> Result.map(fn xs ->
  HTTPClient.with_token(List.first(xs), List.last(xs))
end)
|> Result.unwrap()
