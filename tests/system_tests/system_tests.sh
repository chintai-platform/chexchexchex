#!/bin/bash

source $CHEXCHEXCHEX_DIR/tests/system_tests/global.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/create_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/transfer_tests.sh
source $CHEXCHEXCHEX_DIR/tests/system_tests/burn_tests.sh

run_all_tests(){
  echo "Running all tests"
  create_tests
  transfer_tests
  burn_tests
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
