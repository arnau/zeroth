# Zeroth

Zeroth is a tool to interact with Auth0's Management API.

## Features

* [ ] Client Grants.
* [x] [Clients](lib/zeroth/client.ex).
* [ ] Connections.
* [ ] Device Credentials.
* [ ] Grants.
* [x] [Logs](lib/zeroth/log.ex).
* [ ] Resource Servers.
* [ ] Rules.
* [ ] User Blocks.
* [x] [Users](lib/zeroth/user.ex).
* [ ] Blacklists.
* [ ] Emails.
* [ ] Guardian.
* [ ] Jobs.
* [ ] Stats.
* [ ] Tenants.
* [ ] Admin.
* [ ] Tickets.

Although the intended usage is via `iex` to have a flexible environment to
interact with, there is the aim to provide a few `mix` tasks to surface
common tasks.

### Mix tasks

* `zeroth.gen.token` Generates a token to use with other commands.
* `zeroth.logs` Lists recent logs.

## Documentation

For now, read it in the source code or fire up `iex -S mix` and `h Zeroth`.

## Installation

Currently, there is no stable release. Use it at your own risk.

```elixir
def deps do
  [{:zeroth, git: "https://github.com/arnau/zeroth.git"}]
end
```

## License

Zeroth is distributed under the terms of the MIT License. See
[LICENSE](LICENSE) for details.
