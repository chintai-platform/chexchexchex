#!/bin/bash

function create_tests()
{
  local quantity=1000000000.00000000
  local symbol=CHEX
  local precision=8
  create_success 
  create_wrong_authority 
  create_token_already_exists 
  create_wrong_quantity_amount 
}

function create_success()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  
  local result=$( (cleos push action -f $chex_contract create "[\"$chex_contract\" \"$quantity $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi

  local stats_table=$(cleos get table $chex_contract $symbol stat)
  local supply=$(echo $stats_table | jq -r .rows[0].supply)
  local max_supply=$(echo $stats_table | jq -r .rows[0].max_supply)
  local issuer=$(echo $stats_table | jq -r .rows[0].issuer)

  if [[ $supply != "0.00000000 $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: Expected a supply of \"0.00000000 $symbol\" but observed \"$supply\""
    return 1
  fi

  if [[ $max_supply != "$quantity $symbol" ]]
  then
    test_fail "${FUNCNAME[0]}: Expected a max supply of \"$quantity $symbol\" but observed \"$max_supply\""
    return 1
  fi

  if [[ $issuer != $chex_contract ]]
  then
    test_fail "${FUNCNAME[0]}: Expected issuer to be \"$chex_contract\", but observed \"$issuer\""
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function create_wrong_authority()
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

  local result=$( (cleos push action -f $chex_contract create "[\"$chex_contract\" \"$quantity $symbol\"]" -p $account1) 2>&1)
  if [[ $result != *"Missing required authority"* ]]
  then
    test_fail "${FUNCNAME[0]}: account1 managed to create some tokens, but only chex_contract should be capable of that: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function create_token_already_exists()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi

  local result=$( (cleos push action -f $chex_contract create "[\"$chex_contract\" \"$quantity $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to create $symbol token: $result"
    return 1
  fi

  local result=$( (cleos push action -f $chex_contract create "[\"$chex_contract\" \"$quantity $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $result != *"Token with symbol already exists"* ]]
  then
    test_fail "${FUNCNAME[0]}: Managed to create the token again, even though it already exists: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function create_wrong_quantity_amount()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi

  local result=$( (cleos push action -f $chex_contract create "[\"$chex_contract\" \"-1.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $result != *"Maximum supply must be positive"* ]]
  then
    test_fail "${FUNCNAME[0]}: Managed to create a token with negative maximum supply: $result"
    return 1
  fi

  local result=$( (cleos push action -f $chex_contract create "[\"$chex_contract\" \"0.00000000 $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $result != *"Maximum supply must be positive"* ]]
  then
    test_fail "${FUNCNAME[0]}: Managed to create a token with zero maximum supply: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
