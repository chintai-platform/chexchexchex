#!/bin/bash

accounts=(blockprodaaa blockprodaab blockprodaac blockprodaad blockprodaae blockprodaaf blockprodaag blockprodaah blockprodaai blockprodaaj blockprodaak blockprodaal blockprodaam blockprodaan blockprodaao blockprodaap blockprodaaq blockprodaar blockprodaas blockprodaat)
foo=($(cleos create key --to-console))
cleos wallet import --private-key ${foo[2]}
cleos system newaccount eosio --transfer thevoter ${foo[5]} --stake-net "200000000.0000 EOS" --stake-cpu "200000000.0000 EOS" --buy-ram "200000000.0000 EOS"

cleos system regproducer eosio EOS6bpCbibfKRV4UDGV8yJRnEExMUR4Bjz9dPyxuYWFwj35TW7hks
cleos system voteproducer prods thevoter eosio

