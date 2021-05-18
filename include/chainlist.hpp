#ifndef CHAINLIST
#define CHAINLIST

#include <eosio/eosio.hpp>

namespace chex
{
  class [[eosio::contract("chexchexchex"), eosio::table("chainlist")]] chain_list
  {
    private:
      eosio::name     chain;
    public:
      eosio::name get_chain() const { return chain; }

      void set_chain( eosio::name const &_chain ) { chain = _chain; }

      uint64_t primary_key()const { return chain.value; }

      EOSLIB_SERIALIZE(chain_list, (chain))
  };

  typedef eosio::multi_index< "chainlist"_n, chain_list > chainlist;
}

#endif
