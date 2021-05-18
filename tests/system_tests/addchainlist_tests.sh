#!/bin/bash

function addchainlist_tests()
{
  local chain=bsc
  addchainlist_success &
  addchainlist_wrong_authority &
}

function addchainlist_success()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract addchainlist "[$chain]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The addchainlist failed"
    return 1
  fi

  local chain_entry=$(cleos get table $chex_contract $chex_contract chainlist | jq -r .rows[].chain)
  if [[ $chain_entry != $chain ]]
  then
    test_fail "${FUNCNAME[0]}: The chainlist entry was incorrect, expected \"$chain\" but observed \"$chain_entry\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function addchainlist_wrong_authority()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local account1=$(create_random_account)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account1"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract addchainlist "[$chain]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The addchainlist succeeded, despite the account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

