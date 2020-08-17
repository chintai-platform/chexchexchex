#!/bin/bash

function lock_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  lock_success &
  lock_wrong_authority &
  lock_wrong_quantity_amount &
  lock_wrong_quantity_symbol &
  lock_wrong_time &
  lock_low_balance &
  lock_already_locked &
}

function lock_no_locked_balance()
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
    test_fail "Failed to create $symbol token: $result"
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

  local account1_balance_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_lock\""
    return 1
  fi

  local account1_locked_before_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_before_lock != "0.00000000 $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_locked_before_lock\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The lock failed although it should have succeeded: $result"
    return 1
  fi

  local account1_balance_after_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_after_lock\""
    return 1
  fi

  local account1_locked_after_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_after_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_locked_after_lock\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_partially_locked_balance()
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
    test_fail "Failed to create $symbol token: $result"
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
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_locked_before_lock\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$unlocked_quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The lock failed although it should have succeeded: $result"
    return 1
  fi

  local account1_balance_after_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_after_lock\""
    return 1
  fi

  local account1_locked_after_lock=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_after_lock != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_locked_after_lock\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_success()
{
  lock_no_locked_balance &
  lock_partially_locked_balance &
}

function lock_wrong_authority()
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
    test_fail "Failed to create $symbol token: $result"
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

  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $account2) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite the from account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite the from account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_wrong_quantity_amount()
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
    test_fail "Failed to create $symbol token: $result"
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

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"0.00000000 $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite quantity being zero"
    return 1
  fi
  result=$( (cleos push action -f $chex_contract lock "[$account1 \"-1.00000000 $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite quantity being negative"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_wrong_quantity_symbol()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: failed to create account1: $account1"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity FAKE\" 1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite symbol being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_wrong_time()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"1000000000.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: failed to create account1: $account1"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" -1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite the time being -1"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 0]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite the time being 0"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 101]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite the time being 101"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_low_balance()
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
    test_fail "Failed to create $symbol token: $result"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The lock succeeded, despite account1 having not enough funds"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function lock_already_locked()
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
    test_fail "Failed to create $symbol token: $result"
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

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Locked tokens, although they were already locked"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
