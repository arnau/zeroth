defprotocol Zeroth.Api do
  def get(client)

  def post(client, body, headers \\ %{})

  def update_endpoint(client, path)
  def put_endpoint(client, endpoint)
end
