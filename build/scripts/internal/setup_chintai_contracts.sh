#!/bin/bash

foo=($(cleos create key --to-console))
cleos wallet import --private-key ${foo[2]}
cleos system newaccount eosio --transfer chexchexchex ${foo[5]} --stake-net "100000.0000 EOS" --stake-cpu "100000.0000 EOS" --buy-ram "1000 EOS"
cleos set account permission chexchexchex active '{"threshold": 1, "keys":[{"key":"'${foo[5]}'", "weight":1}], "accounts":[{"permission":{"actor":"chexchexchex","permission":"eosio.code"},"weight":1}], "waits":[] }' owner -p chexchexchex
