defmodule Zeroth do
  @moduledoc """
  Zeroth. Auth0 management in Elixir.

  This package provides a set of ready to use mix tasks to interact with the
  [Management API](https://auth0.com/docs/api/management/v2).

  ```sh
  mix list | grep zeroth
  ```

  It offers an Elixir API as well. To get started you need to obtain a token
  using a client id and client secret. A convenient way is to use the
  environment variables `AUTH0_HOST`, `AUTH0_CLIENT_ID` and
  `AUTH0_CLIENT_SECRET` combined with `Zeroth.HTTPClient.from_env/0`.

  ```elixir
  alias Zeroth.HTTPClient
  alias Zeroth.Token
  alias Zeroth.Client

  {:ok, api_client} = HTTPClient.from_env()
  {:ok, token} = Token.fetch(api_client)
  api_client = HTTPClient.with_token(api_client, token)

  clients = Client.all(api_client) #=> [%Client{...}, ...]
  ```

  If you don't want to rely on environment variables, you can use
  `Zeroth.HTTPClient.from_list/1` instead.

  ```elixir
  {:ok, api_client} = Zeroth.HTTPClient.from_list(client_id: "...", 
                                                  client_secret: "...",
                                                  host: "https://...")
  ```
  """
end
