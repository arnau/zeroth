defprotocol Zeroth.Api do
  def get(client, options \\ [])

  def post(client, body, options \\ [])

  def update_endpoint(client, path)
  def put_endpoint(client, endpoint)
end
