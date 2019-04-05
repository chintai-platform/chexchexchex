project(chexchexchex)

set(EOSIO_WASM_OLD_BEHAVIOR "Off")
find_package(eosio.cdt)

add_contract( chexchexchex chexchexchex chexchexchex.cpp )
target_include_directories( chexchexchex PUBLIC ${CMAKE_SOURCE_DIR}/../include )
target_ricardian_directory( chexchexchex ${CMAKE_SOURCE_DIR}/../ricardian )