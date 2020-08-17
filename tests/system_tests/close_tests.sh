#!/bin/bash

function close_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  close_success &
  close_wrong_authority &
  close_wrong_symbol &
  close_already_closed &
}

function close_success()
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

  result=$( (cleos push action -f $chex_contract open "[$account1 \"$precision,$symbol\" $account1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The open action failed although it should have succeeded: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract close "[$account1 \"$precision,$symbol\"]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The close action failed although it should have succeeded: $result"
    return 1
  fi

  local account1_balance_after_transfer=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_transfer != "null" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"null\" but observed \"$account1_balance_after_transfer\""
    return 1
  fi

  local account2=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account2: $account2"
    return 1
  fi

  result=$(helper_send_token $account2 $quantity $symbol $chex_contract $chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "The transfer failed although it should have succeeded: $result"
    return 1
  fi

  result=$( (cleos push action $chex_contract burn "[$account2 \"$quantity $symbol\"]" -p $account2) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The burn failed although it should have succeeded: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract close "[$account2 \"$precision,$symbol\"]" -p $account2) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The close action failed after burning the users funds, although it should have succeeded: $result"
    return 1
  fi

  local account2_balance_after_transfer=$(cleos get table $chex_contract $account2 accounts | jq -r .rows[0].balance)
  if [[ $account2_balance_after_transfer != "null" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account2 is incorrect, expected \"null\" but observed \"$account2_balance_after_transfer\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function close_wrong_authority()
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

  result=$( (cleos push action -f $chex_contract close "[$account1 \"$precision,$symbol\"]" -p $account2) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The close action succeeded, despite the ram_payer account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract close "[$account1 \"$precision,$symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The close action succeeded, despite the ram_payer account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function close_wrong_symbol()
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

  result=$( (cleos push action -f $chex_contract close "[$account1 \"FAKE,8\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The close action succeeded, despite symbol being incorrect"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract close "[$account1 \"CHEX,4\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The close action succeeded, despite symbol being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function close_already_closed()
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

  result=$( (cleos push action -f $chex_contract close "[$account1 \"$symbol,$precision\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The close action succeeded, despite the account table not containing account1"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

