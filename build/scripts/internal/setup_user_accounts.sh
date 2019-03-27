#!/bin/bash

accounts=(phillhamnett mikefletcher andrewcoutts)
for i in  "${accounts[@]}"
do
  foo=($(cleos -u http://127.0.0.1:8888 create key --to-console))
  cleos -u http://127.0.0.1:8888 wallet import --private-key ${foo[2]}
  cleos -u http://127.0.0.1:8888 system newaccount eosio --transfer $i ${foo[5]} --stake-net "100000.0000 EOS" --stake-cpu "100000.0000 EOS" --buy-ram "10 EOS"
  cleos -u http://127.0.0.1:8888 transfer eosio $i "30000 EOS"
  cleos -u http://127.0.0.1:8888 system regproducer $i ${foo[5]} 
done

