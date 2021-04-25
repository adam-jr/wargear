defmodule Wargear.Nishant.TradeAlert do
  defstruct(
    :symbol,
    :expiry,
    :call_debit?,
    :long_strike,
    :short_strike,
    :limit_price,
    :asset_price_at_time_of_alert,
    :alerted_at
  )

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
end
