#!/bin/bash

trap 'clean_exit' SIGINT

echo -e "\e[33mSetting up the testing environment\e[0m"

private_key=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
public_key=EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV

echo 0 > tests_passed
echo 0 > tests_failed
echo 0 > tests_total

test_lock=./test_status.lock

clean_exit(){
  close_nodeos
  exit_code=$?
  rm -f tests_passed
  rm -f tests_failed
  rm -f tests_total
  rm -rf $test_lock
  exit $exit_code
}

test_pass(){
  while true
  do
    result=$( (mkdir $test_lock) 2>&1)
    if [[ $? -eq 0 ]]
    then
      break
    fi
  done
  echo -e "\e[32mTest Passed: $@\e[0m"
  local tests_passed=$(cat tests_passed)
  local tests_total=$(cat tests_total)
  tests_passed=$(echo "$tests_passed+1" | bc)
  tests_total=$(echo "$tests_total+1 " | bc)
  echo $tests_passed > tests_passed
  echo $tests_total > tests_total
  rmdir $test_lock
}

test_fail(){
  while true
  do
    result=$( (mkdir $test_lock) 2>&1)
    if [[ $? -eq 0 ]]
    then
      break
    fi
  done
  echo -e "\e[31mTest Failed: \e[0m$@"
  local tests_failed=$(cat tests_failed)
  local tests_total=$(cat tests_total)
  tests_failed=$(echo "$tests_failed+1" | bc)
  tests_total=$(echo "$tests_total+1" | bc)
  echo $tests_failed > tests_failed
  echo $tests_total > tests_total
  rmdir $test_lock
}

setup_nodeos(){
  echo -e "\e[33mSetting up nodeos\e[0m"
  result=$( (killall nodeos) 2>&1)
  nodeos --delete-all-blocks --config-dir $CHEXCHEXCHEX_DIR/scripts/ -c config.ini >& nodeos.log &
  nodeos_pid=$!
  if [[ $? -ne 0 ]]
  then
    echo "Nodeos failed to start"
    cat nodeos.log
    exit 1
  fi
  sleep 1 # Necessary to give enough time for nodeos to get started before running any commands on nodeos
}

setup_wallet(){
  echo -e "\e[33mSetting up wallet\e[0m"
  rm -f ~/eosio-wallet/localtestnet.wallet
  result=$( (cleos wallet create -n localtestnet -f localtestnet.key) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo $result
    exit 1
  fi
  result=$( (cleos wallet unlock -n localtestnet --password $(cat localtestnet.key) ) 2>& 1)
  result=$( (cleos wallet import -n localtestnet --private-key $private_key) 2>&1)
}

# Timeout function
# Used to attempt a function multiple times
# Arguments are: 
# $1 command to execute
# $2 timeout limit
timeout(){
  COUNTER=0
  while [ $COUNTER -lt $2 ]; do
    result=$( ( $1 ) 2>& 1 )
    if [[ $? -eq 0 ]]
    then break
    fi
    let COUNTER=COUNTER+1 
    if [[ $COUNTER -eq $2 ]]
    then
      echo "Failure when trying to execute: \"$1\": \"$result\""
      return 1
    fi
  done
}

setup_system_contracts(){
  echo -e "\e[33mSetting up system contracts\e[0m"
  accounts=(bpay msig names ram ramfee saving stake token vpay rex)

  for i in  "${accounts[@]}"
  do
    result=$( (cleos create account eosio eosio.$i $public_key -p eosio) 2>&1)
    if [[ $? -ne 0 ]]
    then
      echo "Failed to create account eosio.$i"
      echo $result
    fi
  done

  timeout "cleos set contract eosio.token $EOSIO_CONTRACTS_DIRECTORY/build/contracts//eosio.token" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract eosio.token"
  fi
  timeout "cleos set contract eosio.msig $EOSIO_CONTRACTS_DIRECTORY/build/contracts//eosio.msig" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract eosio.msig"
  fi
  result=$( (cleos push action -f eosio.token create '[ "eosio", "10000000000.0000 EOS" ]' -p eosio.token) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create EOS tokens with eosio.token"
    echo $result
  fi
  result=$( (cleos push action -f eosio.token issue '[ "eosio", "1000000000.0000 EOS", "memo" ]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to issue EOS tokens to eosio"
    echo $result
  fi

  result=$( (curl -s -X POST http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}') 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to preactivate feature"
    echo $result
  fi

  sleep 0.5

  timeout "cleos set contract eosio $EOSIO_OLD_CONTRACTS_DIRECTORY/build/contracts//eosio.system" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract for eosio"
  fi

  result=$( (cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi
  result=$( (cleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio@active) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to activate feature"
    echo $result
  fi

  sleep 0.5

  timeout "cleos set contract eosio $EOSIO_CONTRACTS_DIRECTORY/build/contracts//eosio.system" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set contract for eosio"
  fi

  result=$( (cleos push action eosio init '{"version":"0","core":"4,EOS"}' -p eosio) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo $result
  fi
}

function generate_random_name()
{
  echo $(head /dev/urandom | tr -dc a-z1-5 | head -c 12 ; echo '')
}

function create_random_account()
{
  account=$(generate_random_name)
  result=$( (cleos system newaccount eosio $account $public_key --stake-net "100000 EOS" --stake-cpu "100000 EOS" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $account: $result"
    return 1
  fi
  echo $account
}

setup_chex_contract(){
  local account=$(generate_random_name)
  result=$( (cleos system newaccount eosio $account $public_key --stake-net "100000 EOS" --stake-cpu "100000 EOS" --buy-ram-kbytes 10000) 2>&1)
  if [[ $? -ne 0 ]]
  then
    echo "Failed to create account $account: $result"
    return 1
  fi
  timeout "cleos set contract $account $CHEXCHEXCHEX_DIR/build/chexchexchex" 20
  if [[ $? -ne 0 ]]
  then
    echo "Failed to set chexchexchex contract"
    return 1
  fi
  echo $account
}

setup_system(){
  setup_nodeos
  setup_wallet
  setup_system_contracts
}

close_nodeos(){
  echo -e "\e[33mClosing nodeos\e[0m"
  tests_passed=$(cat tests_passed)
  tests_failed=$(cat tests_failed)
  tests_total=$(cat tests_total)
  killall nodeos
  if [[ $tests_passed -gt 0 ]]
  then echo -e "\e[32m$tests_passed/$tests_total Passed\e[0m"
  fi
  if [[ $tests_failed -gt 0 ]]
  then echo -e "\e[31m$tests_failed/$tests_total Failed\e[0m"
  fi
  return $tests_failed
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
