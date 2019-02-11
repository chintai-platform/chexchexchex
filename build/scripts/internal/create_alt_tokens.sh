#!/bin/bash
cleos set contract phillhamnett $EOSIO_CONTRACT_DIR/build/contracts/eosio.token
cleos push action -f phillhamnett create '[ "phillhamnett", "10000000000.0000 EOS" ]' -p phillhamnett
cleos push action -f phillhamnett issue '[ "phillhamnett", "1000000000.0000 EOS", "memo" ]' -p phillhamnett
cleos push action -f phillhamnett create '[ "phillhamnett", "10000000000.0000 ABC" ]' -p phillhamnett
cleos push action -f phillhamnett issue '[ "phillhamnett", "1000000000.0000 ABC", "memo" ]' -p phillhamnett
cleos push action -f phillhamnett create '[ "phillhamnett", "10000000000.0000 DEF" ]' -p phillhamnett
cleos push action -f phillhamnett issue '[ "phillhamnett", "1000000000.0000 DEF", "memo" ]' -p phillhamnett

