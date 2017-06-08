defmodule Zeroth.User.Enrollment do
  @moduledoc false

  defstruct [:id,
             :status,
             :type,
             :name,
             :identifier,
             :phone_number,
             :auth_method,
             :enrolled_at,
             :last_auth]
end
