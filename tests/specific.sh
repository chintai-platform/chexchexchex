#!/bin/bash

setup_chex_contract(){
  local chexchexchex=$(generate_random_name)
  result=$( (cleos system newaccount eosio $chexchexchex $public_key --stake-net "100000.00000000 CHEX" --stake-cpu "100000.00000000 CHEX" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $chexchexchex: $result"
    return 1
  fi
  result=$( (cleos set contract $chexchexchex $CHEXCHEXCHEX_DIR/builds/test/chexchexchex chexchexchex.wasm chexchexchex.abi) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set chexchexchex contract"
    return 1
  fi
  result=$( (cleos set account permission $chexchexchex active --add-code) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set up eosio.code permission for chex contract"
    return 1
  fi
  echo $chexchexchex
}

function helper_send_token()
{
  account=$1
  quantity=$2
  symbol=$3
  contract=$4
  issuer=$5

  if [[ $quantity != "0.0000" ]]
  then
    result=$( (cleos push action -f $contract issue "[$issuer, \"$quantity $symbol\", \"memo\"]" -p $issuer) 2>&1)
    if [[ $? -ne 0 ]]
    then 
      echo "Failed to issue $quantity $symbol to $contract: $result"
      return 1
    fi
    if [[ $issuer != $account ]]
    then
      result=$( (cleos push action -f $contract transfer "[$issuer, $account, \"$quantity $symbol\", \"memo\"]" -p $issuer) 2>&1)
      if [[ $? -ne 0 ]]
      then 
        echo "Failed to transfer $quantity $symbol to $account: $result"
        return 1
      fi
    fi
  fi
}
