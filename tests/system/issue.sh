#!/bin/bash

function issue_tests()
{
  local quantity=100.00000000
  local symbol=CHEX
  local precision=8
  local max_supply_quantity=1000000000.00000000
  issue_success 
  issue_wrong_authority 
  issue_wrong_receiver 
  issue_wrong_quantity_amount 
  issue_wrong_quantity_symbol 
  issue_max_supply_reached 
}

function issue_success()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
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

  result=$( (cleos push action -f $chex_contract issue "[$account1, \"$quantity $symbol\", \"memo\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "The issue failed although it should have succeeded: $result"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function issue_wrong_authority()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
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

  result=$( (cleos push action -f $chex_contract issue "[$account1, \"$quantity $symbol\", \"memo\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite the from account not being the authorizer"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract issue "[$chex_contract, \"$quantity $symbol\", \"memo\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite the from account not being the authorizer"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function issue_wrong_receiver()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "Failed to create $symbol token: $result"
    return 1
  fi

  local account1=$(generate_random_name)
  result=$( (cleos push action -f $chex_contract issue "[$account1, \"$quantity $symbol\", \"memo\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite the to account not existing"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function issue_wrong_quantity_amount()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
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

  result=$( (cleos push action -f $chex_contract issue "[$account1, \"0.00000000 $symbol\", \"memo\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite quantity being zero"
    return 1
  fi
  result=$( (cleos push action -f $chex_contract issue "[$account1, \"-1.00000000 $symbol\", \"memo\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite quantity being negative"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function issue_wrong_quantity_symbol()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
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
    test_fail "${FUNCNAME[0]}: Failed to create account1: $account2"
    return 1
  fi
  result=$( (helper_send_token $account1 $quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract issue "[$account1, $account2, \"$quantity FAKE\", \"memo\"]" -p $account1) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite symbol being incorrect"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function issue_max_supply_reached()
{
  issue_from_zero_to_more_than_max 
  issue_from_max 
}

function issue_from_zero_to_more_than_max()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
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

  local quantity=$(echo "scale=8; ($max_supply_quantity + $quantity) / 1.0" | bc)

  result=$( (cleos push action -f $chex_contract issue "[$account1, \"$quantity $symbol\", \"memo\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite being more than the max supply"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}

function issue_from_max()
{
  local chex_contract=$(setup_chex_contract)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to set chex contract: $chex_contract"
    return 1
  fi
  local result=$( (cleos push action $chex_contract create "[\"$chex_contract\" \"$max_supply_quantity $symbol\"]" -p $chex_contract) 2>&1)
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
  result=$( (helper_send_token $account1 $max_supply_quantity $symbol $chex_contract $chex_contract) 2>&1)
  if [[ $? -ne 0 ]]
  then
    test_fail "${FUNCNAME[0]}: Failed to generate tokens for test: $result"
    return 1
  fi

  result=$( (cleos push action -f $chex_contract issue "[$account1, \"$quantity $symbol\", \"memo\"]" -p $chex_contract) 2>&1)
  if [[ $? -eq 0 ]]
  then
    test_fail "The issue succeeded, despite being more than the max supply"
    return 1
  fi

  test_pass "${FUNCNAME[0]}"
}
