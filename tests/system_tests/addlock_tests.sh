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
  result=$( (cleos push action -f $chex_contract mockopenfail "[$account1]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: The open action failed although it should have succeeded: $result"
    return 1
  fi
  result=$( (cleos get table $chex_contract $account1 accounts | jq -r .rows[0]) 2>&1)
  local locked=$(echo $result | jq -r .locked)
  if [[ $locked != "0 " ]]
  then
    test_fail "${FUNCNAME[0]}: The locked balance should show \"0 \" for this test after mockopenfail, but it shows \"$locked\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract addlock "[$account1]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail ${FUNCNAME[0]}: "The addlock action failed although it should have succeeded: $result"
    return 1
  fi
  result=$( (cleos get table $chex_contract $account1 accounts | jq -r .rows[0]) 2>&1)
  locked=$(echo $result | jq -r .locked)
  if [[ $locked != "0.00000000 CHEX" ]]
  then
    test_fail "${FUNCNAME[0]}: The locked balance should show \"0.00000000 CHEX\" after calling addlock, but it shows $locked"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
