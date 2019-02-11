#!/bin/bash

accounts=(phillhamnett mikefletcher andrewcoutts)
for i in  "${accounts[@]}"
do
  foo=($(cleos create key --to-console))
  cleos wallet import --private-key ${foo[2]}
  cleos system newaccount eosio --transfer $i ${foo[5]} --stake-net "100000.0000 EOS" --stake-cpu "100000.0000 EOS" --buy-ram "10 EOS"
  cleos transfer eosio $i "30000 EOS"
  cleos system regproducer $i ${foo[5]} 
done

