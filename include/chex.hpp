/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */
#pragma once

#include <eosio/asset.hpp>
#include <eosio/eosio.hpp>
#include <eosio/time.hpp>
#include <eosio/system.hpp>

#include <string>

namespace eosiosystem {
   class system_contract;
}
using namespace eosio;
namespace chex{

   using std::string;

   class [[eosio::contract("token")]] token : public contract {
      public:
         using contract::contract;

         [[eosio::action]]
         void create( name   issuer,
                      asset  maximum_supply);

         [[eosio::action]]
         void issue( name to, asset quantity, string memo );

         [[eosio::action]]
         void retire( asset quantity, string memo );

         [[eosio::action]]
         void transfer( name    from,
                        name    to,
                        asset   quantity,
                        string  memo );

         [[eosio::action]]
         void open( name owner, const symbol& symbol, name ram_payer );

         [[eosio::action]]
         void close( name owner, const symbol& symbol );

         [[eosio::action]]
         void lock( name owner, asset quantity, uint8_t days);

         [[eosio::action]]
         void unlock( name owner, asset quantity );

         [[eosio::action]]
         void burn( name owner, asset quantity );

         [[eosio::action]]
         void refund( name owner );

         [[eosio::action]]
         void lock2balance( name owner );

         [[eosio::action]]
         void nonce( uint128_t nonce );

         void convert_locked_to_balance( name owner );

         static asset get_supply( name token_contract_account, symbol_code sym_code )
         {
            stats statstable( token_contract_account, sym_code.raw() );
            const auto& st = statstable.get( sym_code.raw() );
            return st.supply;
         }

         static asset get_balance( name token_contract_account, name owner, symbol_code sym_code )
         {
            accounts accountstable( token_contract_account, owner.value );
            const auto& ac = accountstable.get( sym_code.raw() );
            return ac.balance;
         }

         //[[eosio::action]]
         //void deletetable(name owner, asset token)
         //{
         //  require_auth(_self);
         //  accounts from_acnts( _self, owner.value );
         //  locked_funds locked( _self,  owner.value );
         //  stats statstable( _self, token.symbol.code().raw() );
         //  unlocking_funds unlocking( _self, owner.value );
         //  print("Test 1");
         //  auto it1 = from_acnts.begin();
         //  print("Test 2");
         //  auto it2 = locked.begin();
         //  print("Test 3");
         //  auto it3 = statstable.begin();
         //  print("Test 4");
         //  auto it4 = unlocking.begin();
         //  print("Test 5");
         //  while(it1 != from_acnts.end()) it1 = from_acnts.erase(it1);
         //  print("Test 6");
         //  while(it2 != locked.end()) it2 = locked.erase(it2);
         //  print("Test 7");
         //  while(it3 != statstable.end()) it3 = statstable.erase(it3);
         //  print("Test 8");
         //  while(it4 != unlocking.end()) it4 = unlocking.erase(it4);
         //  print("Test 9");
         //}

         using create_action = eosio::action_wrapper<"create"_n, &token::create>;
         using issue_action = eosio::action_wrapper<"issue"_n, &token::issue>;
         using retire_action = eosio::action_wrapper<"retire"_n, &token::retire>;
         using transfer_action = eosio::action_wrapper<"transfer"_n, &token::transfer>;
         using open_action = eosio::action_wrapper<"open"_n, &token::open>;
         using close_action = eosio::action_wrapper<"close"_n, &token::close>;
      private:
         struct [[eosio::table]] account {
            asset    balance;
            asset    locked;
            uint64_t primary_key()const { return balance.symbol.code().raw(); }
         };

         struct [[eosio::table]] currency_stats {
            asset    supply;
            asset    max_supply;
            name     issuer;

            uint64_t primary_key()const { return supply.symbol.code().raw(); }
         };

         struct [[eosio::table]] locked_fund {
            uint64_t lock_time;
            asset    quantity;
            uint64_t primary_key()const { return lock_time; }
         };

         struct [[eosio::table]] unlocking_fund {
            uint64_t id;
            time_point unlocked_at;
            asset    quantity;
            uint64_t primary_key()const { return id; }
         };

         typedef eosio::multi_index< "accounts"_n, account > accounts;
         typedef eosio::multi_index< "stat"_n, currency_stats > stats;
         typedef eosio::multi_index< "locked"_n, locked_fund > locked_funds;
         typedef eosio::multi_index< "unlocking"_n, unlocking_fund > unlocking_funds;

         void sub_balance( name owner, asset value );
         void add_balance( name owner, asset value, name ram_payer );
   };

} /// namespace eosio
