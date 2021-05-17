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

   class [[eosio::contract("chexchexchex")]] token : public contract {
      public:
         using contract::contract;

         [[eosio::action]]
         void create( name   issuer,
                      asset  maximum_supply);

         [[eosio::action]]
         void issue( name to, asset quantity, string memo );

         [[eosio::action]]
         void transfer( name    from,
                        name    to,
                        asset   quantity,
                        string  memo );

         [[eosio::action]]
         void trnsferchain( name    from,
                            std::string to,
                            asset   quantity,
                            string  memo,
                            eosio::name chain );

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
         void retire( name owner, asset quantity );

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

         using create_action = eosio::action_wrapper<"create"_n, &token::create>;
         using issue_action = eosio::action_wrapper<"issue"_n, &token::issue>;
         using transfer_action = eosio::action_wrapper<"transfer"_n, &token::transfer>;
         using open_action = eosio::action_wrapper<"open"_n, &token::open>;
         using close_action = eosio::action_wrapper<"close"_n, &token::close>;

#if LOCAL
         [[eosio::action]]
           void mockopenfail(eosio::name const & account)
           {
             require_auth(get_self());
             accounts table(get_self(), account.value);
             auto addentry = [&](auto & entry)
             {
               entry.balance = eosio::asset(0, eosio::symbol("CHEX",8));
             };
             if(table.begin() == table.end())
             {
               table.emplace(get_self(), addentry);
             }
             else
             {
               table.modify(table.begin(), get_self(), addentry);
             }
           }
#endif

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
