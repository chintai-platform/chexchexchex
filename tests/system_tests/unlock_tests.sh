#!/bin/bash

function unlock_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  unlock_success &
  unlock_wrong_authority &
  unlock_wrong_receiver &
  unlock_wrong_quantity_amount &
  unlock_wrong_quantity_symbol &
  unlock_no_locked_balance &
  unlock_no_balance &
}

function unlock_partially_locked_balance()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  local locked_quantity=$(echo "scale=8; $quantity / 2.0" | bc)
  local unlocked_quantity=$(echo "scale=8; ($quantity - $locked_quantity)/1.0" | bc)

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$locked_quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi
  
  local account1_balance_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_lock\""
    return 1
  fi

  local account1_locked_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_before_lock != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$locked_quantity $symbol\" but observed \"$account1_locked_before_lock\" (first lock)"
    return 1
  fi

  local lock_time=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].lock_time)
  if [[ $lock_time != "1" ]]
  then
    test_fail "${FUNCNAME[0]}: The lock time is expected to be \"1\", but observed \"$lock_time\""
    return 1
  fi

  local lock_table_quantity=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].quantity)
  if [[ $lock_table_quantity != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked quantity is expected to be \"$locked_quantity $symbol\", but observed \"$lock_table_quantity\""
    return 1
  fi

  local time_before_unlock=$(echo "$(date "+%s" -u) + 86400" | bc)
  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$locked_quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock failed although it should have succeeded: $result"
    return 1
  fi
  local time_after_unlock=$(echo "$(date "+%s" -u) + 86401" | bc)

  local lock_time=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].lock_time)
  if [[ $lock_time != "null" ]]
  then
    test_fail "${FUNCNAME[0]}: The lock time is expected to be \"null\", but observed \"$lock_time\""
    return 1
  fi

  local lock_table_quantity=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].quantity)
  if [[ $lock_table_quantity != "null" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked quantity is expected to be \"null\", but observed \"$lock_table_quantity\""
    return 1
  fi

  local account1_balance_after_unlock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_unlock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_after_unlock\""
    return 1
  fi

  local unlocking_fund_id=$(cleos get table $chex_contract $account1 unlocking | jq -r .rows[0].id)
  if [[ $unlocking_fund_id != "0" ]]
  then
    test_fail "${FUNCNAME[0]}: The unlocking table id is not zero"
    return 1
  fi

  local unlocking_fund_unlocked_at=$(date -d "$(cleos get table $chex_contract $account1 unlocking | jq -r .rows[0].unlocked_at)" "+%s")
  #if [[ $unlocking_fund_unlocked_at -lt $time_before_unlock || $unlocking_fund_unlocked_at -gt $time_after_unlock ]]
  #then
  #  test_fail "${FUNCNAME[0]}: Expected the unlock time to be between $time_before_unlock and $time_after_unlock, but observed it at $unlocking_fund_unlocked_at"
  #  return 1
  #fi

  local unlocking_fund_quantity=$(cleos get table $chex_contract $account1 unlocking | jq -r .rows[0].quantity)
  if [[ $unlocking_fund_quantity != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$locked_quantity $symbol\" but observed \"$unlocking_fund_quantity\" (third lock)"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function unlock_multiple_locked_balance()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  local locked_quantity=$(echo "scale=8; $quantity / 4.0" | bc)
  local unlocked_quantity=$(echo "scale=8; ($quantity - $locked_quantity)/1.0" | bc)

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$locked_quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi
  
  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$locked_quantity $symbol\" 2]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi
  
  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$locked_quantity $symbol\" 3]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi

  local total_locked=$(echo "scale=8; 3*$quantity/4.0" | bc)
  
  local account1_balance_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_lock\""
    return 1
  fi

  local account1_locked_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_before_lock != "$total_locked $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$total_locked $symbol\" but observed \"$account1_locked_before_lock\" (1)"
    return 1
  fi

  local lock_time=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].lock_time)
  if [[ $lock_time != "1" ]]
  then
    test_fail "${FUNCNAME[0]}: The lock time is expected to be \"1\", but observed \"$lock_time\" (1)"
    return 1
  fi

  local lock_table_quantity=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].quantity)
  if [[ $lock_table_quantity != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked quantity is expected to be \"$locked_quantity $symbol\", but observed \"$lock_table_quantity\""
    return 1
  fi

  local time_before_unlock=$(date -u "+%Y-%m-%dT%H:%M:%S")
  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$locked_quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock failed although it should have succeeded: $result"
    return 1
  fi
  local time_after_unlock=$(date -u "+%Y-%m-%dT%H:%M:%S")

  local lock_time=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].lock_time)
  if [[ $lock_time != "2" ]]
  then
    test_fail "${FUNCNAME[0]}: The lock time is expected to be \"1\", but observed \"$lock_time\" (2)"
    return 1
  fi

  local lock_table_quantity=$(cleos get table $chex_contract $account1 locked | jq -r .rows[0].quantity)
  if [[ $lock_table_quantity != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked quantity is expected to be \"$locked_quantity $symbol\", but observed \"$lock_table_quantity\""
    return 1
  fi

  local account1_balance_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_lock\""
    return 1
  fi

  local account1_locked_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_before_lock != "$total_locked $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_locked_before_lock\" (2)"
    return 1
  fi

  local unlocking_fund_id=$(cleos get table $chex_contract $account1 unlocking | jq -r .rows[0].id)
  if [[ $unlocking_fund_id != "0" ]]
  then
    test_fail "${FUNCNAME[0]}: The unlocking table id is not zero"
    return 1
  fi

  local unlocking_fund_unlocked_at=$(cleos get table $chex_contract $account1 unlocking | jq -r .rows[0].unlocked_at)
#  if [[ "$unlocking_fund_unlocked_at" < "$time_before_unlock" || "$unlocking_fund_unlocked_at" > "$time_after_unlock" ]]
#  then
#    test_fail "${FUNCNAME[0]}: Expected the unlock time to be between $time_before_unlock and $time_after_unlock, but observed it at $unlocking_fund_unlocked_at"
#    return 1
#  fi

  local unlocking_fund_quantity=$(cleos get table $chex_contract $account1 unlocking | jq -r .rows[0].quantity)
  if [[ $unlocking_fund_quantity != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$unlocking_fund_quantity\" (3)"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}


function unlock_success()
{
  unlock_partially_locked_balance
  unlock_multiple_locked_balance
}

function unlock_wrong_authority()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi

  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  local account2=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account2: $account2"
    return 1
  fi
  local account3=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account3: $account3"
    return 1
  fi

  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $account2) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite the from account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $account3) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite the from account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite the from account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function unlock_wrong_receiver()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  local account2=$(generate_random_name)
  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite the to account not existing"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function unlock_wrong_quantity_amount()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  local account2=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account2"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1, $account2, \"0.00000000 $symbol\", \"memo\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite quantity being zero"
    return 1
  fi
  result=$( (cleos push action -f $chex_contract unlock "[$account1, $account2, \"-1.00000000 $symbol\", \"memo\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite quantity being negative"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function unlock_wrong_quantity_symbol()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  local account2=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account2"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1, $account2, \"$quantity FAKE\", \"memo\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite symbol being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function unlock_no_locked_balance()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  local account1_balance_before_unlock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_unlock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_unlock\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded although it should have failed"
    return 1
  fi
  test_pass "${FUNCNAME[0]}"
}

function unlock_no_balance()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite account1 having no funds"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function unlock_when_locked()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi
  local account2=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account2"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi
  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract unlock "[$account1 \"$quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The unlock succeeded, despite account1 having its funds locked up"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
