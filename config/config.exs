use Mix.Config

config(:zeroth, [host: System.get_env("AUTH0_HOST"),
                 client_id: System.get_env("AUTH0_CLIENT_ID"),
                 client_secret: System.get_env("AUTH0_CLIENT_SECRET")])


# And access this configuration in your application as:
#
#     Application.get_env(:zeroth, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
