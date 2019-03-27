#!/bin/bash

foo=($(cleos -u http://127.0.0.1:8888 create key --to-console))
cleos -u http://127.0.0.1:8888 wallet import --private-key ${foo[2]}
cleos -u http://127.0.0.1:8888 system newaccount eosio --transfer chexchexchex ${foo[5]} --stake-net "100000.0000 EOS" --stake-cpu "100000.0000 EOS" --buy-ram "1000 EOS"
cleos -u http://127.0.0.1:8888 set account permission chexchexchex active '{"threshold": 1, "keys":[{"key":"'${foo[5]}'", "weight":1}], "accounts":[{"permission":{"actor":"chexchexchex","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p chexchexchex
