#!/bin/bash

function addlock_tests()
{
  addlock_success
}

function addlock_success()
{
  local chex_contract=$(setup_chex_contract)
  local precision=8
  local symbol=CHEX
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
  result=$( (cleos get table $chex_contract $account1 accounts | jq -r .rows[0]) 2>&1)

  result=$( (cleos push action -f $chex_contract addlock "[$account1]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail ${FUNCNAME[0]}: "The addlock action failed although it should have succeeded: $result"
    return 1
  fi
  result=$( (cleos get table $chex_contract $account1 accounts | jq -r .rows[0]) 2>&1)
}
