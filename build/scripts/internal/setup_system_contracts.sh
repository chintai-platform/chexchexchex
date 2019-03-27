#!/bin/bash

accounts=(bpay msig names ram ramfee saving stake token vpay)

for i in  "${accounts[@]}"
do
  foo=($(cleos -u http://127.0.0.1:8888 create key --to-console))
  cleos -u http://127.0.0.1:8888 wallet import --private-key ${foo[2]}
  cleos -u http://127.0.0.1:8888 create account eosio eosio.$i ${foo[5]} -p eosio
done

cleos -u http://127.0.0.1:8888 set contract eosio.token $EOSIO_CONTRACT_DIR/build/contracts/eosio.token
cleos -u http://127.0.0.1:8888 set contract eosio.msig $EOSIO_CONTRACT_DIR/build/contracts/eosio.msig
cleos -u http://127.0.0.1:8888 push action -f eosio.token create '[ "eosio", "10000000000.0000 EOS" ]' -p eosio.token
cleos -u http://127.0.0.1:8888 push action -f eosio.token issue '[ "eosio", "1000000000.0000 EOS", "memo" ]' -p eosio
cleos -u http://127.0.0.1:8888 set contract eosio $EOSIO_CONTRACT_DIR/build/contracts/eosio.system
cleos -u http://127.0.0.1:8888 push action eosio init '{"version":"0","core":"4,EOS"}' -p eosio
