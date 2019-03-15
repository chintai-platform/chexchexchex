#!/bin/bash

accounts=(bpay msig names ram ramfee saving stake token vpay)

for i in  "${accounts[@]}"
do
  foo=($(cleos create key --to-console))
  cleos wallet import --private-key ${foo[2]}
  cleos create account eosio eosio.$i ${foo[5]} -p eosio
done

cleos set contract eosio.token $EOSIO_CONTRACT_DIR/contracts/eosio.token
cleos set contract eosio.msig $EOSIO_CONTRACT_DIR/contracts/eosio.msig
cleos push action -f eosio.token create '[ "eosio", "10000000000.0000 EOS" ]' -p eosio.token
cleos push action -f eosio.token issue '[ "eosio", "1000000000.0000 EOS", "memo" ]' -p eosio
cleos set contract eosio $EOSIO_CONTRACT_DIR/contracts/eosio.system
cleos push action eosio init '{"version":"0","core":"4,EOS"}' -p eosio
