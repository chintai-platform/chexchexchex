#!/bin/bash

function open_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  open_success &
  open_wrong_authority &
  open_wrong_symbol &
  open_wrong_account &
}

function open_success()
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

  result=$( (cleos push action -f $chex_contract open "[$account1 \"$precision,$symbol\" $account1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action failed although it should have succeeded: $result"
    return 1
  fi

  local account1_balance_after_transfer=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].balance)
  if [[ $account1_balance_after_transfer != "0.00000000 $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The balance of account1 is incorrect, expected \"0.00000000 $symbol\" but observed \"$account1_balance_after_transfer\""
    return 1
  fi

  local account1_locked_after_transfer=$(cleos get table $chex_contract $account1 accounts | jq -r .rows[0].locked)
  if [[ $account1_locked_after_transfer != "0.00000000 $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked of account1 is incorrect, expected \"0.00000000 $symbol\" but observed \"$account1_locked_after_transfer\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract open "[$account1 \"$precision,$symbol\" $account1]" -p $account1) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action failed after it succeeded the first time, although it should have succeeded: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function open_wrong_authority()
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

  result=$( (cleos push action -f $chex_contract open "[$account1 \"$precision,$symbol\" $account2]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action succeeded, despite the ram_payer account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function open_wrong_account()
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

  local account2=$(generate_random_name)
  result=$( (cleos push action -f $chex_contract open "[$account2 \"$precision,$symbol\" $account1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action succeeded, despite account2 not existing"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function open_wrong_symbol()
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

  result=$( (cleos push action -f $chex_contract open "[$account1 \"FAKE,8\" $account1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action succeeded, despite symbol being incorrect"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract open "[$account1 \"CHEX,4\" $account1]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action succeeded, despite symbol being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

