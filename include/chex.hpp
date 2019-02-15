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
         void stake( eosio::name owner, eosio::asset quantity );

         [[eosio::action]]
         void unstake( eosio::name owner, eosio::asset quantity );

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
            eosio::asset    staked;
            eosio::asset    unstaking;
            account() : balance(0, eosio::symbol("CHEX",4)), staked(0, eosio::symbol("CHEX",4)), unstaking(0, eosio::symbol("CHEX",4)) {}
            uint64_t primary_key()const { return balance.symbol.code().raw(); }
            EOSLIB_SERIALIZE( account, (balance)(staked)(unstaking) )
         };

         struct [[eosio::table]] staked {
           eosio::time_point      staked_at;
            eosio::asset    balance;
            staked() : staked_at(eosio::microseconds(0)), balance(0, eosio::symbol("CHEX",4)) {}
            uint64_t primary_key()const { return staked_at.sec_since_epoch(); }
            EOSLIB_SERIALIZE( staked, (staked_at)(balance) )
         };

         struct [[eosio::table]] unstaked {
           eosio::time_point      unstaked_at;
           eosio::asset    balance;
            unstaked() : unstaked_at(eosio::microseconds(0)), balance(0, eosio::symbol("CHEX",4)) {}

            uint64_t primary_key()const { return unstaked_at.sec_since_epoch(); }
            EOSLIB_SERIALIZE( unstaked, (unstaked_at)(balance) )
         };

         struct [[eosio::table]] currency_stats {
            eosio::asset                   supply;
            eosio::asset                   max_supply;
            eosio::name                    issuer;
            eosio::asset                   total_staked;
            std::vector< eosio::asset >    total_staked_per_level;

            currency_stats() : supply(0, eosio::symbol("CHEX",4)), max_supply(0, eosio::symbol("CHEX",4)), issuer("chexchexchex"), total_staked(0, eosio::symbol("CHEX",4)) {eosio::print("Test\n");}
            uint64_t primary_key()const { return supply.symbol.code().raw(); }
            EOSLIB_SERIALIZE( currency_stats, (supply)(max_supply)(issuer)(total_staked)(total_staked_per_level) )
         };

         typedef eosio::multi_index< "accounts"_n, account > accounts;
         typedef eosio::multi_index< "stat"_n, currency_stats > stats;
         typedef eosio::multi_index< "staked"_n, staked> staked_table;
         typedef eosio::multi_index< "unstaked"_n, unstaked > unstaked_table;

         void sub_balance( eosio::name owner, eosio::asset value );
         void add_balance( eosio::name owner, eosio::asset value, eosio::name ram_payer );
   };

} /// eosio::namespace eosio
