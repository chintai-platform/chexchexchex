#!/bin/bash

accounts=(blockprodaaa blockprodaab blockprodaac blockprodaad blockprodaae blockprodaaf blockprodaag blockprodaah blockprodaai blockprodaaj blockprodaak blockprodaal blockprodaam blockprodaan blockprodaao blockprodaap blockprodaaq blockprodaar blockprodaas blockprodaat)
foo=($(cleos create key --to-console))
cleos wallet import --private-key ${foo[2]}
cleos system newaccount eosio --transfer thevoter ${foo[5]} --stake-net "200000000.0000 EOS" --stake-cpu "200000000.0000 EOS" --buy-ram "200000000.0000 EOS"
#cleos system newaccount eosio --transfer blockprodaaa EOS6tA3y6EGPsZB4G4UGgWpXK4BgxMhEzDYjFZep1RoeLiH7X8az5 --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaab EOS513GqqnU3VKQrsVKWHDksnke5MQHPxbwNjyf7oAiMAj2MsVA58 --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaac EOS5Bn2AsNN6WnCLe4XE2UJ9DnfshQDsxBszYCDVgHoPLXtp1Q13a --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaad EOS6EWUBmyHrokaeLp9NNdmA9FtwcpNZsV7jssTunLQto4d7UgYLa --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaae EOS7dHhHgedBvZ3MBL5eYTNqBVzwLrEge2NCQ7QFSRKEmSqiCyXEN --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaaf EOS6o3wZvtM1VUCdY2WYLiqPENHXZqByqhwpBkkdb8zkCiJ9ADeb8 --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaag EOS5zZ3zeKwzcvfY7Wpkhvvut8aPScAgeqMQmP4SJoaSkHBRCNHvg --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaah EOS7hwuMe6QEFPG3oFAoSvX846NUMCqj7e6GZPjMYGNkoLjwA7rhb --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaai EOS5uPg8Z2wU9wwjuY7aAJRWu3tkPYLjAbgPVbu3U3SBCeAFwstve --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaaj EOS5DdwubST3pCKr7moPLEJMZUH8Czg9mUaCDhRfvxK9gNcPvajHa --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaak EOS4yEUpyCej1iZ1AJqU3iDM2vfvWu5AU5kYPmp8oQTUqtJ6LiBoy --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaal EOS8LHDWWUD2t3qYABuUKj1RLnWBFcmoBditwGtD6WcqfHN1dAHRg --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaam EOS6XTjoC5SNwr4igMadVc1upsyJn6of4qyJWZxPsw8QPybhqMD4z --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaan EOS6JPv7zBLKW1k2YsBtXVhgaKDEwoA15TbxB7LqYo7roHJM7MuC4 --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaao EOS52b4zN8o3wZSCyGv9hKbkmRUsE3B9R2JqU3sxD82EbPF5qTqPM --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaap EOS732V39fWNtdX5vfNbPiLmkrkfFPqRQpTYoYVBbD3D7HQMpNh8W --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaaq EOS5wGaKHNqHcetJzh277JXjb4hebgKbEnYBdtzmvpdz94RK5onbw --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaar EOS4uvcATSWdAaZSkyoQZu8s8zyvDqfKSPKaLWRvf39SeAZRft6kg --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaas EOS8VUXHJbHjZqUFVogBxqPnSP7gjMBt5hBtmnbL9mc7TVsAibgVq --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos system newaccount eosio --transfer blockprodaat EOS6dLBaCMNBChzjWucsQCzWLzikcXTGFruyfE6WhGYzxfacuC3AT --stake-net "1000.0000 EOS" --stake-cpu "1000.0000 EOS" --buy-ram "1000 EOS"
#cleos wallet import --private-key 5J2NEUnRVFr2pbHw9QGuCeY61t8cQ3jqge7G2H2wr4WkS57pTFS
#cleos wallet import --private-key 5JPo4r37muedogdwsvLdVtksz4bjWXjnodWnyWh78Kg8j5fHi12
#cleos wallet import --private-key 5JHgecAX1hHEun8RobTzVVxhtnyptjmqocEHHMkXVy2q1UrEpge
#cleos wallet import --private-key 5KiAXPanMF8Nu2d389Y813qH5P8zemsjrACVL6UFMPgwweJ7DGA
#cleos wallet import --private-key 5K5igHRpWhVfXy1HGamReDnkRtoNd7kxdU9eh4giJWM2NSsyKTW
#cleos wallet import --private-key 5KdCdWN3ca26Eqg1xQ1ww7MDZVfApMsXdYpHLnuSK33kFGpPAzj
#cleos wallet import --private-key 5JMjsLC8CmUU4xkEAWzJqcy7HECgCF1DZrX8HSCjG73dwxQy56X
#cleos wallet import --private-key 5JHziMMRF37wW5vFbh5qjsbvZ79rYZaKr7heDWjWoR23bxYu7TR
#cleos wallet import --private-key 5JZc8BPV1rFJ9nnECZvyVTqzMdc5vprV6ZZpjc7mNoWdNNPK12w
#cleos wallet import --private-key 5JReKMcj5CK76ZvGKdyG2SoRrX77L2bSzgKow1iyyi4ZWkMrVd9
#cleos wallet import --private-key 5JvrfdN3Btbs2K9J1r7MbS6u13d2nNcv86us8rm5CwS8cRvzku7
#cleos wallet import --private-key 5J5G81WjGrBPAbTb638P1NP8E4dLX3jnQxt18ZA3PzMxX8VfRQY
#cleos wallet import --private-key 5HsFFEEVK1WLCzinyMbMGRN9eCwy5gSQhNP53fBR1y63wr8Dyh2
#cleos wallet import --private-key 5J5XGCVjvdxhzgyc74DiAfFJTiVQ9LZ1YGLjqkZf6YmEenPTFd9
#cleos wallet import --private-key 5K894szk4uZ1CEHUsBTG7eoyDQ1YdPuDoHyL14YXJXagMqsPHpL
#cleos wallet import --private-key 5Jkr8ghpJf7wz42HAGqK6x2Zy5ptb6PY8xaHf1xxgYV19LTMGQh
#cleos wallet import --private-key 5Kjnt3wvzBMVeVxY9WU6W7KgphcnahKrYhnTFjHxvbfFWKhpyyq
#cleos wallet import --private-key 5JKip8E543xEhMDMLU7JN2wAnLJMmSkfJ7Fei6tgeSXZAUvzLjf
#cleos wallet import --private-key 5J2rbcQsukmsQnc7eWkPBWkf3jj5FUJuvXbSwK2sqpkXdJaXGhd
#cleos wallet import --private-key 5KQMJKM2oHiXgE4V5Zh5aFWLqbTxTjahmgHm8rJYae5T7yMa5ZH
#cleos wallet import --private-key 5JQg6m9q3UWW3AHDow8fim6v4v2eL9VpckayakNLKhYuhB4EoEL
#cleos system regproducer blockprodaaa EOS6tA3y6EGPsZB4G4UGgWpXK4BgxMhEzDYjFZep1RoeLiH7X8az5
#cleos system regproducer blockprodaab EOS513GqqnU3VKQrsVKWHDksnke5MQHPxbwNjyf7oAiMAj2MsVA58
#cleos system regproducer blockprodaac EOS5Bn2AsNN6WnCLe4XE2UJ9DnfshQDsxBszYCDVgHoPLXtp1Q13a
#cleos system regproducer blockprodaad EOS6EWUBmyHrokaeLp9NNdmA9FtwcpNZsV7jssTunLQto4d7UgYLa
#cleos system regproducer blockprodaae EOS7dHhHgedBvZ3MBL5eYTNqBVzwLrEge2NCQ7QFSRKEmSqiCyXEN
#cleos system regproducer blockprodaaf EOS6o3wZvtM1VUCdY2WYLiqPENHXZqByqhwpBkkdb8zkCiJ9ADeb8
#cleos system regproducer blockprodaag EOS5zZ3zeKwzcvfY7Wpkhvvut8aPScAgeqMQmP4SJoaSkHBRCNHvg
#cleos system regproducer blockprodaah EOS7hwuMe6QEFPG3oFAoSvX846NUMCqj7e6GZPjMYGNkoLjwA7rhb
#cleos system regproducer blockprodaai EOS5uPg8Z2wU9wwjuY7aAJRWu3tkPYLjAbgPVbu3U3SBCeAFwstve
#cleos system regproducer blockprodaaj EOS5DdwubST3pCKr7moPLEJMZUH8Czg9mUaCDhRfvxK9gNcPvajHa
#cleos system regproducer blockprodaak EOS4yEUpyCej1iZ1AJqU3iDM2vfvWu5AU5kYPmp8oQTUqtJ6LiBoy
#cleos system regproducer blockprodaal EOS8LHDWWUD2t3qYABuUKj1RLnWBFcmoBditwGtD6WcqfHN1dAHRg
#cleos system regproducer blockprodaam EOS6XTjoC5SNwr4igMadVc1upsyJn6of4qyJWZxPsw8QPybhqMD4z
#cleos system regproducer blockprodaan EOS6JPv7zBLKW1k2YsBtXVhgaKDEwoA15TbxB7LqYo7roHJM7MuC4
#cleos system regproducer blockprodaao EOS52b4zN8o3wZSCyGv9hKbkmRUsE3B9R2JqU3sxD82EbPF5qTqPM
#cleos system regproducer blockprodaap EOS732V39fWNtdX5vfNbPiLmkrkfFPqRQpTYoYVBbD3D7HQMpNh8W
#cleos system regproducer blockprodaaq EOS5wGaKHNqHcetJzh277JXjb4hebgKbEnYBdtzmvpdz94RK5onbw
#cleos system regproducer blockprodaar EOS4uvcATSWdAaZSkyoQZu8s8zyvDqfKSPKaLWRvf39SeAZRft6kg
#cleos system regproducer blockprodaas EOS8VUXHJbHjZqUFVogBxqPnSP7gjMBt5hBtmnbL9mc7TVsAibgVq
#cleos system regproducer blockprodaat EOS6dLBaCMNBChzjWucsQCzWLzikcXTGFruyfE6WhGYzxfacuC3AT
#for i in "${accounts[@]}"
#do
#  cleos system voteproducer prods thevoter $i
#done
cleos system regproducer eosio EOS6bpCbibfKRV4UDGV8yJRnEExMUR4Bjz9dPyxuYWFwj35TW7hks
cleos system voteproducer prods thevoter eosio

