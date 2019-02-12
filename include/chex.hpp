/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */
#pragma once

#include <eosiolib/asset.hpp>
#include <eosiolib/eosio.hpp>
#include <eosiolib/time.hpp>

#include <string>

namespace chintai
{

   using std::string;

   class [[eosio::contract("chexchexchex")]] token : public eosio::contract {
      public:
         using contract::contract;

         [[eosio::action]]
         void create( eosio::name   issuer,
                      eosio::asset  maximum_supply);

         [[eosio::action]]
         void issue( eosio::name to, eosio::asset quantity, string memo );

         [[eosio::action]]
         void retire( eosio::asset quantity, string memo );

         [[eosio::action]]
         void burn( eosio::name owner, eosio::asset quantity, string memo );

         [[eosio::action]]
         void transfer( eosio::name    from,
                        eosio::name    to,
                        eosio::asset   quantity,
                        string  memo );

         [[eosio::action]]
         void open( eosio::name owner, eosio::symbol const & symbol, eosio::name ram_payer );

         [[eosio::action]]
         void close( eosio::name owner, eosio::symbol const & symbol );

         static eosio::asset get_supply( eosio::name token_contract_account, eosio::symbol_code sym_code )
         {
            stats statstable( token_contract_account, sym_code.raw() );
            const auto& st = statstable.get( sym_code.raw() );
            return st.supply;
         }

         static eosio::asset get_balance( eosio::name token_contract_account, eosio::name owner, eosio::symbol_code sym_code )
         {
            accounts accountstable( token_contract_account, owner.value );
            const auto& ac = accountstable.get( sym_code.raw() );
            return ac.balance;
         }

      private:
         struct [[eosio::table]] account {
            eosio::asset    balance;

            uint64_t primary_key()const { return balance.symbol.code().raw(); }
         };

         struct [[eosio::table]] stake {
           eosio::time_point      staked_at;
            eosio::asset    balance;

            uint64_t primary_key()const { return staked_at.sec_since_epoch(); }
         };

         struct [[eosio::table]] unstake {
           eosio::time_point      unstaked_at;
            eosio::asset    balance;

            uint64_t primary_key()const { return unstaked_at.sec_since_epoch(); }
         };

         struct [[eosio::table]] currency_stats {
            eosio::asset                   supply;
            eosio::asset                   max_supply;
            eosio::name                    issuer;
            eosio::asset                   total_staked;
            std::vector< eosio::asset >    total_staked_per_level;

            uint64_t primary_key()const { return supply.symbol.code().raw(); }
         };

         typedef eosio::multi_index< "accounts"_n, account > accounts;
         typedef eosio::multi_index< "stat"_n, currency_stats > stats;

         void sub_balance( eosio::name owner, eosio::asset value );
         void add_balance( eosio::name owner, eosio::asset value, eosio::name ram_payer );
   };

} /// eosio::namespace eosio
