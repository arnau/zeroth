alias Zeroth.HTTPClient
alias Zeroth.Token
alias Zeroth.Client

{:ok, api_client} = HTTPClient.from_env()
{:ok, token} = Token.fetch(api_client)
api_client = HTTPClient.with_token(api_client, token)
