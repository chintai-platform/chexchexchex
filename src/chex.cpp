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
    eosio::print("1\n");
    require_auth( _self );
    eosio::print("2\n");

    auto sym = maximum_supply.symbol;
    eosio::print("3\n");
    eosio::check( sym.is_valid(), "invalid symbol name" );
    eosio::print("4\n");
    eosio::check( maximum_supply.is_valid(), "invalid supply");
    eosio::print("5\n");
    eosio::check( maximum_supply.amount > 0, "max-supply must be positive");
    eosio::print("6\n");

    stats statstable( _self, sym.code().raw() );
    eosio::print("7\n");
    auto existing = statstable.find( sym.code().raw() );
    eosio::print("8\n");
    eosio::check( existing == statstable.end(), "token with symbol already exists" );
    eosio::print("9\n");

    statstable.emplace( _self, [&]( auto& s ) {
    eosio::print("10\n");
        s.supply.symbol       = maximum_supply.symbol;
    eosio::print("11\n");
        s.max_supply          = maximum_supply;
    eosio::print("12\n");
        s.issuer              = issuer;
    eosio::print("13\n");
        s.total_staked.symbol = maximum_supply.symbol;
    eosio::print("14\n");
        for(int i = 0; i < 7; ++i)
        {
    eosio::print("15\n");
          s.total_staked_per_level.push_back(s.supply);
    eosio::print("16\n");
        }
    eosio::print("17\n");
        });
    eosio::print("18\n");
  }


  /*!
    Issue token
  */
  void token::issue( eosio::name to, eosio::asset quantity, string memo )
  {
    eosio::print("19\n");
    auto sym = quantity.symbol;
    eosio::print("20\n");
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );
    eosio::print("21\n");
    eosio::check( memo.size() <= 256, "memo has more than 256 bytes" );
    eosio::print("22\n");

    stats statstable( _self, sym.code().raw() );
    eosio::print("23\n");
    auto existing = statstable.find( sym.code().raw() );
    eosio::print("24\n");
    eosio::check( existing != statstable.end(), "token with symbol does not exist, create token before issue" );
    eosio::print("25\n");
    const auto& st = *existing;
    eosio::print("26\n");

    require_auth( st.issuer );
    eosio::print("27\n");
    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::print("28\n");
    eosio::check( quantity.amount > 0, "must issue positive quantity" );
    eosio::print("29\n");

    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );
    eosio::print("30\n");
    eosio::check( quantity.amount <= st.max_supply.amount - st.supply.amount, "quantity exceeds available supply");
    eosio::print("31\n");

    statstable.modify( st, eosio::same_payer, [&]( auto& s ) {
    eosio::print("32\n");
        s.supply += quantity;
    eosio::print("33\n");
        });

    eosio::print("34\n");
    add_balance( st.issuer, quantity, st.issuer );
    eosio::print("35\n");

    if( to != st.issuer ) {
      SEND_INLINE_ACTION( *this, transfer, { {st.issuer, "active"_n} },
          { st.issuer, to, quantity, memo }
          );
    }
    eosio::print("36\n");
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
    eosio::print(sym,"\n");
    eosio::print(sym.raw(),"\n");
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );

    stats statstable( _self, sym.code().raw() );
    eosio::print("Accessing stats table\n");
    const auto& st = statstable.find( sym.code().raw() );
    eosio::check(st != statstable.end(), "Currency does not exist");
    eosio::print("Accessed stats table\n");

    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must transfer positive quantity" );
    print(quantity.symbol,"\n");
    eosio::check( quantity.symbol == st->supply.symbol, "symbol precision mismatch" );

    accounts from_acnts( _self, owner.value );
    eosio::print("Accessing accounts table\n");
    const auto& from = from_acnts.get( quantity.symbol.code().raw(), "no balance object found" );
    eosio::check( from.balance.amount >= quantity.amount, "overdrawn balance" );
    from_acnts.modify(from, eosio::same_payer, [&](auto & entry){
        eosio::print("Adding ",quantity," to ",entry.balance,"\n");
        eosio::print("Adding ",quantity," to ",entry.staked,"\n");
        entry.balance -= quantity;
        entry.staked += quantity;
        });

    staked_table _staked_table(_self, owner.value);
    _staked_table.emplace(owner, [&](auto & entry){
        eosio::print("Adding ",quantity," to ",entry.balance,"\n");
         entry.balance = quantity;
        });
  }

  /*!
    Unstake tokens
  */
  void token::unstake( eosio::name owner, eosio::asset quantity)
  {
    auto sym = quantity.symbol;
    eosio::check( sym.is_valid(), "invalid symbol eosio::name" );
    stats statstable( _self, sym.code().raw() );
    const auto& st = statstable.get( sym.code().raw() );

    eosio::check( quantity.is_valid(), "invalid quantity" );
    eosio::check( quantity.amount > 0, "must transfer positive quantity" );
    eosio::check( quantity.symbol == st.supply.symbol, "symbol precision mismatch" );

    accounts from_acnts( _self, owner.value );
    const auto& from = from_acnts.get( quantity.symbol.code().raw(), "no balance object found" );
    eosio::check( from.staked.amount >= quantity.amount, "Can't unstake more than is staked" );
    from_acnts.modify(from_acnts.find(quantity.symbol.code().raw()), eosio::same_payer, [&](auto & entry){
        entry.staked -= quantity;
        entry.unstaking += quantity;
        });

    unstaked_table _unstaked_table(_self, owner.value);
    _unstaked_table.emplace(owner, [&](auto & entry){
         entry.balance = quantity;
        });

    staked_table _staked_table(_self, owner.value);
    bool finished(false);
    while(_staked_table.begin() != _staked_table.end() && !finished)
    {
      auto i = _staked_table.rbegin();
      if(i->balance < quantity)
      {
        quantity -= i->balance;
        _staked_table.erase(_staked_table.find(i->primary_key()));
      }
      else
      {
        _staked_table.modify(_staked_table.find(i->primary_key()), owner, [&](auto & entry){
            entry.balance -= quantity;
            });
        finished = true;
      }
    }
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
    eosio::print("37\n");
    accounts to_acnts( _self, owner.value );
    eosio::print("38\n");
    auto to = to_acnts.find( value.symbol.code().raw() );
    eosio::print("39\n");
    if( to == to_acnts.end() ) {
    eosio::print("40\n");
      to_acnts.emplace( ram_payer, [&]( auto& a ){
    eosio::print("41\n");
          a.balance = value;
    eosio::print("42\n");
          });
    eosio::print("43\n");
    } else {
    eosio::print("44\n");
      to_acnts.modify( to, eosio::same_payer, [&]( auto& a ) {
    eosio::print("45\n");
          a.balance += value;
    eosio::print("46\n");
          });
    eosio::print("47\n");
    }
    eosio::print("48\n");
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
