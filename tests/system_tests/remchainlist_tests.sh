#!/bin/bash

function remchainlist_tests()
{
  local chain=bsc
  remchainlist_success &
  remchainlist_wrong_authority &
  remchainlist_entry_does_not_exist &
}

function remchainlist_success()
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
    test_fail "The addchainlist failed: $result"
    return 1
  fi

  local chain_entry_before=$(cleos get table $chex_contract $chex_contract chainlist | jq -r .rows[].chain)
  if [[ $chain_entry_before != $chain ]]
  then
    test_fail "${FUNCNAME[0]}: The chainlist entry before was incorrect, expected \"$chain\" but observed \"$chain_entry_before\""
    return 1
  fi

  result=$( (cleos push action -f $chex_contract remchainlist "[$chain]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The remchainlist failed: $result"
    return 1
  fi

  local chain_entry_after=$(cleos get table $chex_contract $chex_contract chainlist | jq -r .rows[].chain)
  if [[ $chain_entry_after != "" ]]
  then
    test_fail "${FUNCNAME[0]}: The chainlist entry after was incorrect, expected \"\" but observed \"$chain_entry_after\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function remchainlist_wrong_authority()
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

  result=$( (cleos push action -f $chex_contract addchainlist "[$chain]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The addchainlist failed: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract remchainlist "[$chain]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The remchainlist succeeded, despite the account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function remchainlist_entry_does_not_exist()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract remchainlist "[$chain]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The remchainlist succeeded when the table entry did not exist: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
