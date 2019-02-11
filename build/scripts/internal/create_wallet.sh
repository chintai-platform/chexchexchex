#!/bin/bash
rm -rf ~/eosio-wallet
mkdir -p ~/eosio-wallet
cleos wallet create --to-console > ~/default-wallet-key
cleos wallet import --private-key 5JLJHdV3sUEqJN1WGqiDgiagoCM4tPt5Wf2uK5qz1gcPXbGHx3x
cleos wallet import --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
cleos wallet unlock --password $(cat ~/default-wallet-key | cut -d '"' -f 2 | cut -d$'\n' -f 4)
echo "cleos wallet unlock --password \$(cat ~/default-wallet-key | cut -d '\"' -f 2 | cut -d$'\n' -f 4)" > UnlockWallet
chmod +x UnlockWallet
