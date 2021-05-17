#!/bin/bash

function trnsferchain_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  local chain=bsc
  trnsferchain_success &
  trnsferchain_wrong_authority &
  trnsferchain_wrong_chain &
  trnsferchain_wrong_quantity_amount &
  trnsferchain_wrong_quantity_symbol &
  trnsferchain_no_balance &
  trnsferchain_when_locked &
}

function trnsferchain_no_locked_balance()
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

  local account1_balance_before_trnsferchain=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_trnsferchain != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_trnsferchain\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain failed although it should have succeeded: $result"
    return 1
  fi

  local account1_balance_after_trnsferchain=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_trnsferchain != "0.00000000 $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"0.00000000 $symbol\" but observed \"$account1_balance_after_trnsferchain\""
    return 1
  fi

  local account2_balance_after_trnsferchain=$(cleos get table $chex_contract $account2 accounts | jq -r .rows[0].balance)
  if [[ $account2_balance_after_trnsferchain != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account2_balance_after_trnsferchain\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_partially_locked_balance()
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

  local locked_quantity=$(echo "scale=8; $quantity / 2.0" | bc)
  local unlocked_quantity=$(echo "scale=8; ($quantity - $locked_quantity)/1.0" | bc)

  result=$( (cleos push action -f $chex_contract lock "[$account1 \"$locked_quantity $symbol\" 1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to lock tokens: $result"
    return 1
  fi

  local account1_balance_before_trnsferchain=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_before_trnsferchain != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$quantity $symbol\" but observed \"$account1_balance_before_trnsferchain\""
    return 1
  fi

  local account1_locked_before_trnsferchain=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_before_trnsferchain != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$locked_quantity $symbol\" but observed \"$account1_locked_before_trnsferchain\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$unlocked_quantity $symbol\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain failed although it should have succeeded: $result"
    return 1
  fi

  local account1_balance_after_trnsferchain=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_trnsferchain != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"$locked_quantity $symbol\" but observed \"$account1_balance_after_trnsferchain\""
    return 1
  fi

  local account2_balance_after_trnsferchain=$(cleos get table $chex_contract $account2 accounts | jq -r .rows[0].balance)
  if [[ $account2_balance_after_trnsferchain != "$unlocked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account2 is incorrect, expected \"$unlocked_quantity $symbol\" but observed \"$account2_balance_after_trnsferchain\""
    return 1
  fi

  local account1_locked_after_trnsferchain=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_after_trnsferchain != "$locked_quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"$locked_quantity $symbol\" but observed \"$account1_locked_after_trnsferchain\""
    return 1
  fi

  local account2_locked_after_trnsferchain=$(cleos get table $chex_contract $account2 accounts | jq -r .rows[0].locked)
  if [[ $account2_locked_after_trnsferchain != "0.00000000 $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account2 is incorrect, expected \"0.00000000 $symbol\" but observed \"$account2_locked_after_trnsferchain\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_success()
{
  trnsferchain_no_locked_balance
  trnsferchain_partially_locked_balance
}

function trnsferchain_wrong_authority()
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

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"$chain\"]" -p $account2) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite the from account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"$chain\"]" -p $account3) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite the from account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"$chain\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite the from account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_wrong_quantity_amount()
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

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"0.00000000 $symbol\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite quantity being zero"
    return 1
  fi
  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"-1.00000000 $symbol\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite quantity being negative"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_wrong_quantity_symbol()
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

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity FAKE\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite symbol being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_wrong_chain()
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

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"wrongchain\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite chain being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_no_balance()
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

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite account1 having no funds"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function trnsferchain_when_locked()
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

  result=$( (cleos push action -f $chex_contract trnsferchain "[$account1, $account2, \"$quantity $symbol\", \"memo\", \"$chain\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The trnsferchain succeeded, despite account1 having its funds locked up"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
