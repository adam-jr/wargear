defmodule Wargear.Nishant.TradeAlert do
  defstruct text: nil,
            symbol: nil,
            expiry: nil,
            call_debit?: true,
            long_strike: nil,
            short_strike: nil,
            limit_price: nil,
            asset_price: nil,
            alerted_at: nil

  """
    +TRADE ALERT
    SYMBOL: BLK
    EXPIRY: 5/28
    TRADE: $795 - $805 Bull Call Spread (Call Debit Spread)
    TRADE BREAKUP: Buy $795 Call, Sell $805 Call for a net debit of $5 (Limit Price)
    COST: $500
    PRICE AT TIME OF TRADE: $796.75
    POTENTIAL PROFIT: $500 (approx)
    ---------------

    NOTES: 
    1. Place this limit order with the above parameters Good For Day.
    2. If the trade gets filled, place a GTC limit order to close it at $9.5
    3. If you have an account < $7K, avoid this trade as it risks $500. Instead try for the $800-$805 Call Spread for $2.5 instead.
  """

  alias Wargear.Discord.Message, as: DiscordMessage

  def from_message(%DiscordMessage{content: text}) do
    %__MODULE__{text: text}
    |> put_prefixed(:symbol, "SYMBOL: ")
    |> put_prefixed(:expiry, "EXPIRY: ")
    |> put_prefixed(:asset_price, "PRICE AT TIME OF TRADE: ")
    |> put_prefixed(:long_strike, "\nTRADE: ", " ")
    |> put_prefixed(:short_strike, " - ", " ")
    |> put_prefixed(:limit_price, "for a net debit of ", " ")
    |> Map.put(:alerted_at, Timex.now())
  end

  def put_prefixed(message, key, prefix, suffix \\ "\n") do
    Map.put(message, key, with_prefix(message.text, prefix, suffix))
  end

  defp with_prefix(text, prefix, suffix) do
    [_hd, rest] = String.split(text, prefix)
    [str|_rest] = String.split(rest, suffix)
    str
  end
end
