#!/bin/bash

function transfer_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  #transfer_success
  transfer_wrong_authority
  #transfer_wrong_receiver
  #transfer_wrong_quantity_amount
  #transfer_wrong_quantity_symbol
  #transfer_no_balance
  #transfer_when_locked
}

function transfer_no_locked_balance()
{
  echo "Warning, no test for transfer_no_locked_balance"
}

function transfer_partially_locked_balance()
{
  echo "Warning, no test for transfer_partially_locked_balance"
}

function transfer_success()
{
  transfer_no_locked_balance
  transfer_partially_locked_balance
}

function transfer_wrong_authority()
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

  result=$( (cleos push action -f $chex_contract transfer "[$account1, $account2, \"$quantity $symbol\", \"memo\"]" -p $account3) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The transfer succeeded, despite the from account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function transfer_wrong_receiver()
{
  echo "Warning, no test for transfer_wrong_receiver"
}

function transfer_wrong_quantity_amount()
{
  echo "Warning, no test for transfer_wrong_quantity_amount"
}

function transfer_wrong_quantity_symbol()
{
  echo "Warning, no test for transfer_wrong_quantity_symbol"
}

function transfer_no_balance()
{
  echo "Warning, no test for transfer_no_balance"
}

function transfer_when_locked()
{
  echo "Warning, no test for transfer_when_locked"
}
