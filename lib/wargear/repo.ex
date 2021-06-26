defmodule Wargear.Repo do
  use Ecto.Repo,
    otp_app: :wargear,
    adapter: Ecto.Adapters.Postgres
end
