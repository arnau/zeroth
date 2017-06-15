defmodule ZerothTest do
  use ExUnit.Case, async: true

  doctest URI.Ext
  doctest Zeroth
  doctest Zeroth.HTTPClient
  doctest Zeroth.Connection
  doctest Zeroth.Credentials
  doctest Zeroth.Token
  doctest Zeroth.Param
end
