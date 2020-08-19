project(chexchexchex)

set(EOSIO_WASM_OLD_BEHAVIOR "Off")
find_package(eosio.cdt)

add_contract( chexchexchex chexchexchex chexchexchex.cpp )
target_include_directories( chexchexchex PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_ricardian_directory( chexchexchex ${CMAKE_SOURCE_DIR}/../ricardian )

add_contract( chexchexchex chexchexchex_local chexchexchex.cpp )
target_include_directories( chexchexchex_local PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_ricardian_directory( chexchexchex_local ${CMAKE_SOURCE_DIR}/../ricardian )
target_compile_definitions( chexchexchex_local PUBLIC LOCAL )
