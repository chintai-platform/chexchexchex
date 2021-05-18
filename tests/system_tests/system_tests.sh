#!/bin/bash

source $CHEXCHEXCHEX_DIR/tests/system_tests/global.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/create_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/transfer_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/burn_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/retire_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/chainlist_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/open_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/close_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/issue_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/lock_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/unlock_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/trnsferchain_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/addchainlist_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/remchainlist_tests.sh

run_all_tests(){
  echo "Running all tests"
  #create_tests
  #transfer_tests
  #burn_tests
  #open_tests
  #close_tests
  #issue_tests
  #lock_tests
  #unlock_tests
  
  trnsferchain_tests
  retire_tests
  addchainlist_tests
  remchainlist_tests
}

run_test_suite(){
  STARTTIME=$(date +%s)
  setup_system
  sleep 1
  run_all_tests
  for job in `jobs -p`
  do
    if [[ $job -ne $nodeos_pid ]]
    then
      wait $job
    fi
  done
  ENDTIME=$(date +%s)
  echo "Tests took $(( ENDTIME - STARTTIME )) second(s) to complete"
  clean_exit 0
}

run_test_suite
