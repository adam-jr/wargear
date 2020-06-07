defmodule Wargear.Turns do

  defmodule Turn do
    defstruct id: nil, type: nil, player: nil, datetime: nil, seat: nil, action: nil, bonus_units: nil, trade_units: nil, attacker: nil, defender: nil, ad: nil, dd: nil, bmod: nil, al: nil, dl: nil
  end

end