/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */

#include <chex.hpp>

namespace chintai
{

  /*!
    Create token
  */
  void token::create( eosio::name issuer, eosio::asset maximum_supply )
  {
    require_auth( _self );

    auto sym = maximum_supply.symbol;
    eosio::check( sym.is_valid(), "invalid symbol name" );
    eosio::check( maximum_supply.is_valid(), "invalid supply");
    eosio::check( maximum_supply.amount > 0, "max-supply must be positive");

    stats statstable( _self, sym.code().raw() );
    auto existing = statstable.find( sym.code().raw() );
    eosio::check( existing == statstable.end(), "token with symbol already exists" );

    statstable.emplace( _self, [&]( auto& s ) {
        s.supply.symbol       = maximum_supply.symbol;
        s.max_supply          = maximum_supply;
        s.issuer              = issuer;
        s.total_staked.symbol = maximum_supply.symbol;
        for(int i = 0; i < 7; ++i)
        {
          s.total_staked_per_level.push_back(s.supply);
        }
        });
  }


  /*!
    Issue token
  */
  void token::issue( eosio::name to, eosio::asset quantity, string memo )
  {
    auto sym = quantity.symbol;
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );
    eosio::check( memo.size() <= 256, "memo has more than 256 bytes" );

    stats statstable( _self, sym.code().raw() );
    auto existing = statstable.find( sym.code().raw() );
    eosio::check( existing != statstable.end(), "token with symbol does not exist, create token before issue" );
    const auto& st = *existing;

    require_auth( st.issuer );
    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must issue positive quantity" );

    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );
    eosio::check( quantity.amount <= st.max_supply.amount - st.supply.amount, "quantity exceeds available supply");

    statstable.modify( st, eosio::same_payer, [&]( auto& s ) {
        s.supply += quantity;
        });

    add_balance( st.issuer, quantity, st.issuer );

    if( to != st.issuer ) {
      SEND_INLINE_ACTION( *this, transfer, { {st.issuer, "active"_n} },
          { st.issuer, to, quantity, memo }
          );
    }
  }

  /*!
    Retire token
    Reduces the total quantity of tokens available by removing them from the issuer
  */
  void token::retire( eosio::asset quantity, string memo )
  {
    auto sym = quantity.symbol;
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );
    eosio::check( memo.size() <= 256, "memo has more than 256 bytes" );

    stats statstable( _self, sym.code().raw() );
    auto existing = statstable.find( sym.code().raw() );
    eosio::check( existing != statstable.end(), "token with symbol does not exist" );
    const auto& st = *existing;

    require_auth( st.issuer );
    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must retire positive quantity" );

    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );

    statstable.modify( st, eosio::same_payer, [&]( auto& s ) {
        s.supply -= quantity;
        });

    sub_balance( st.issuer, quantity );
  }

  /*!
    Retire token
    Reduces the total quantity of tokens available by removing them from the issuer
  */
  void token::burn( eosio::name owner, eosio::asset quantity, string memo )
  {
    auto sym = quantity.symbol;
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );
    eosio::check( memo.size() <= 256, "memo has more than 256 bytes" );

    stats statstable( _self, sym.code().raw() );
    auto existing = statstable.find( sym.code().raw() );
    eosio::check( existing != statstable.end(), "token with symbol does not exist" );
    const auto& st = *existing;

    require_auth( owner );
    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must burn positive quantity" );

    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );

    statstable.modify( st, eosio::same_payer, [&]( auto& s ) {
        s.supply -= quantity;
        s.max_supply -= quantity;
        });

    sub_balance( owner, quantity );
  }

  /*!
    Transfer token
  */
  void token::transfer( eosio::name    from,
      eosio::name    to,
      eosio::asset   quantity,
      string  memo )
  {
    eosio::check( from != to, "cannot transfer to self" );
    require_auth( from );
    eosio::check( is_account( to ), "to account does not exist");
    auto sym = quantity.symbol.code();
    stats statstable( _self, sym.raw() );
    const auto& st = statstable.get( sym.raw() );

    require_recipient( from );
    require_recipient( to );

    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must transfer positive quantity" );
    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );
    eosio::check( memo.size() <= 256, "memo has more than 256 bytes" );

    auto payer = has_auth( to ) ? to : from;

    sub_balance( from, quantity );
    add_balance( to, quantity, payer );
  }

  /*!
    Stake tokens
  */
  void token::stake( eosio::name owner, eosio::asset quantity)
  {
    auto sym = quantity.symbol;
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );
    stats statstable( _self, sym.raw() );
    const auto& st = statstable.get( sym.raw() );
    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must transfer positive quantity" );
    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );
    accounts from_acnts( _self, owner.value );
    const auto& from = from_acnts.get( quantity.symbol.code().raw(), "no balance object found" );
    staked_table _staked_table(_self, owner.value);
    //const auto& stake_bal = 
    eosio::check( from.balance.amount >= quantity.amount, "overdrawn balance" );
    
  }

  /*!
    Subtract token balance from an account
  */
  void token::sub_balance( eosio::name owner, eosio::asset value ) {
    accounts from_acnts( _self, owner.value );

    const auto& from = from_acnts.get( value.symbol.code().raw(), "no balance object found" );
    eosio::check( from.balance.amount >= value.amount, "overdrawn balance" );

    from_acnts.modify( from, owner, [&]( auto& a ) {
        a.balance -= value;
        });
  }

  /*!
    Add token balance to an account
  */
  void token::add_balance( eosio::name owner, eosio::asset value, eosio::name ram_payer )
  {
    accounts to_acnts( _self, owner.value );
    auto to = to_acnts.find( value.symbol.code().raw() );
    if( to == to_acnts.end() ) {
      to_acnts.emplace( ram_payer, [&]( auto& a ){
          a.balance = value;
          });
    } else {
      to_acnts.modify( to, eosio::same_payer, [&]( auto& a ) {
          a.balance += value;
          });
    }
  }

  /*!
    Create a new token balance in table
  */
  void token::open( eosio::name owner, const eosio::symbol& symbol, eosio::name ram_payer )
  {
    require_auth( ram_payer );

    auto sym_code_raw = symbol.code().raw();

    stats statstable( _self, sym_code_raw );
    const auto& st = statstable.get( sym_code_raw, "symbol does not exist" );
    eosio::check( st.supply.symbol == symbol, "symbol precision mismatch" );

    accounts acnts( _self, owner.value );
    auto it = acnts.find( sym_code_raw );
    if( it == acnts.end() ) {
      acnts.emplace( ram_payer, [&]( auto& a ){
          a.balance = eosio::asset{0, symbol};
          });
    }
  }

  /*!
    Remove a token balance in table
  */
  void token::close( eosio::name owner, const eosio::symbol& symbol )
  {
    require_auth( owner );
    accounts acnts( _self, owner.value );
    auto it = acnts.find( symbol.code().raw() );
    eosio::check( it != acnts.end(), "Balance row already deleted or never existed. Action won't have any effect." );
    eosio::check( it->balance.amount == 0, "Cannot close because the balance is not zero." );
    acnts.erase( it );
  }

} 

EOSIO_DISPATCH( chintai::token , (create)(issue)(transfer)(open)(close)(retire)(burn)(stake)(unstake) )
