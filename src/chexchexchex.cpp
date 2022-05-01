/**
 *  @file
 *  @copyright defined in eos/LICENSE.txt
 */

#include "chexchexchex.hpp"
#include <eosio/transaction.hpp>
#include <chrono>

using namespace eosio;
namespace chex{

void check_symbol(eosio::symbol const & sym)
{
  check( sym.is_valid(), "Invalid symbol name: " + sym.code().to_string() );
}

void check_memo_length(string const & memo)
{
  check( memo.size() <= 256, "Memo is too long (" + std::to_string(memo.size()) + " characters). It must be 256 characters or less");
}

void check_quantity(eosio::asset const & quantity)
{
  check( quantity.is_valid(), "Invalid quantity: " + quantity.to_string() );
}

void check_symbol_precision(eosio::symbol const & symbol, eosio::symbol const & stat_symbol)
{
  check( symbol == stat_symbol, "Symbol precision mismatch, make sure that the token name is " + stat_symbol.code().to_string() + ", and that you are specifying it with " + std::to_string(stat_symbol.precision()) + " decimal places of precision" );
}

void token::create( name   issuer,
                    asset  maximum_supply )
{
    require_auth( _self );

    auto sym = maximum_supply.symbol;
    check_symbol(sym);
    check( maximum_supply.is_valid(), "Invalid maximum supply: " + maximum_supply.to_string());
    check( maximum_supply.amount > 0, "Maximum supply must be positive, current amount is set to " + std::to_string(maximum_supply.amount) );

    stats statstable( _self, sym.code().raw() );
    auto existing = statstable.find( sym.code().raw() );
    check( existing == statstable.end(), "Token with symbol already exists (" + sym.code().to_string() + ")" );

    statstable.emplace( _self, [&]( auto& s ) {
       s.supply.symbol = maximum_supply.symbol;
       s.max_supply    = maximum_supply;
       s.issuer        = issuer;
    });
}


void token::issue( name to, asset quantity, string memo )
{
    auto sym = quantity.symbol;

    check_memo_length(memo);
    stats statstable( _self, sym.code().raw() );
    auto existing = statstable.find( sym.code().raw() );
    check( existing != statstable.end(), "Token with symbol " + sym.code().to_string() + " does not exist, create token before issue" );
    const auto& st = *existing;

    require_auth( st.issuer );
    check_quantity(quantity);
    check( quantity.amount > 0, "Must issue positive quantity (quantity amount is " + std::to_string(quantity.amount) + ")" );

    check( quantity.symbol == st.supply.symbol, "Symbol mismatch, expected " + st.supply.symbol.code().to_string() + ", but trying to issue " + quantity.symbol.code().to_string() );
    check( quantity.amount <= st.max_supply.amount - st.supply.amount, "Quantity (" + quantity.to_string() + ") exceeds available supply (" + (st.max_supply - st.supply).to_string() + ")");

    statstable.modify( st, same_payer, [&]( auto& s ) {
       s.supply += quantity;
    });

    add_balance( st.issuer, quantity, st.issuer );

    if( to != st.issuer ) {
      SEND_INLINE_ACTION( *this, transfer, { {st.issuer, "active"_n} },
                          { st.issuer, to, quantity, memo }
      );
    }
}

void token::transfer( name    from,
                      name    to,
                      asset   quantity,
                      string  memo )
{
    check( from != to, "Cannot transfer to self" );
    require_auth(from);
    check( is_account( to ), "Account " + to.to_string() + " does not exist");
    auto sym = quantity.symbol.code();
    stats statstable( _self, sym.raw() );
    const auto& st = statstable.get( sym.raw() );

    require_recipient( from );
    require_recipient( to );

    check_quantity(quantity);
    check( quantity.amount > 0, "Must transfer positive quantity (attmpted to transfer quantity amount of " + std::to_string(quantity.amount) );
    check_symbol_precision(quantity.symbol, st.supply.symbol);
    check_memo_length(memo);
    convert_locked_to_balance( from );

    auto payer = has_auth( to ) ? to : from;

    sub_balance( from, quantity );
    add_balance( to, quantity, payer );
}

void token::retire( name owner, asset quantity )
{
  require_auth(owner);
  convert_locked_to_balance( owner );
  accounts from_acnts( _self, owner.value );
  stats statstable( _self, quantity.symbol.code().raw());
  check( quantity.amount > 0, "Must burn positive quantity (attmpted to burn quantity amount of " + std::to_string(quantity.amount) );
  sub_balance( owner, quantity );
  auto currency = statstable.find(quantity.symbol.code().raw());
  check(currency != statstable.end(), "Invalid token (" + quantity.symbol.code().to_string() + ")");
  statstable.modify( currency, same_payer, [&]( auto & entry )
      {
        entry.supply -= quantity;
      });
}

void token::burn( name owner, asset quantity )
{
  require_auth(owner);
  convert_locked_to_balance( owner );
  accounts from_acnts( _self, owner.value );
  stats statstable( _self, quantity.symbol.code().raw());
  check( quantity.amount > 0, "Must burn positive quantity (attmpted to burn quantity amount of " + std::to_string(quantity.amount) );
  sub_balance( owner, quantity );
  auto currency = statstable.find(quantity.symbol.code().raw());
  check(currency != statstable.end(), "Invalid token (" + quantity.symbol.code().to_string() + ")");
  statstable.modify( currency, same_payer, [&]( auto & entry )
      {
        entry.supply -= quantity;
        entry.max_supply -= quantity;
      });
}

void token::lock( name owner, asset quantity, uint8_t days )
{
  require_auth(owner);
  accounts from_acnts( _self, owner.value );
  auto acnt_itr = from_acnts.find(quantity.symbol.code().raw());
  check(acnt_itr != from_acnts.end(), "Account with this asset does not exist");
  convert_locked_to_balance( owner );
  check(quantity.amount > 0, "Can not lock a negative amount");
  check(acnt_itr->balance - acnt_itr->locked >= quantity, "Not enough unlocked funds available to lock up, the maximum possible quantity that you can lock is " + (acnt_itr->balance - acnt_itr->locked).to_string());
  check(days <= 100, "You can not lock your tokens for more than 100 days");
  check(days > 0, "You can not lock your tokens for less than 1 day");
  from_acnts.modify(acnt_itr, owner, [&](auto & entry)
      {
      entry.locked += quantity;
      });
  locked_funds locked( _self, owner.value );
  auto itr = locked.find(days);
  if(itr == locked.end())
  {
    locked.emplace(owner, [&](auto & entry)
        {
        entry.lock_time = days;
        entry.quantity = quantity;
        });
  }
  else
  {
    locked.modify(itr, owner, [&](auto & entry)
        {
        entry.quantity += quantity;
        });
  }
}

void token::unlock( name owner, asset quantity )
{
  require_auth(owner);
  accounts from_acnts( _self, owner.value );
  locked_funds locked( _self, owner.value );
  unlocking_funds unlocking( _self, owner.value );

  auto acnt_itr = from_acnts.find(quantity.symbol.code().raw());
  check(acnt_itr != from_acnts.end(), "Account with this asset does not exist");
  check(quantity.amount > 0, "Can not unlock a negative amount");
  convert_locked_to_balance( owner );
  check(acnt_itr->locked >= quantity, "You can not unlock more than is currently locked. The maximum you can unlock is " + acnt_itr->locked.to_string());
  eosio::check(locked.begin() != locked.end(), "All funds are currently being unlocked, please wait for the unlock period to end and then the tokens will be available for transfer");

  while(quantity.amount > 0)
  {
    auto locked_itr = locked.begin();
    if(locked_itr == locked.end()) break;
    auto wait = locked_itr->lock_time;
    asset unlock_quantity;
    if(locked_itr->quantity <= quantity)
    {
      unlock_quantity = locked_itr->quantity;
      quantity -= locked_itr->quantity;
      locked.erase(locked_itr);
    }
    else
    {
      unlock_quantity = quantity;
      locked.modify(locked_itr, same_payer, [&](auto & entry)
          {
          entry.quantity -= quantity;
          });
      quantity.amount = 0;
    }
    unlocking.emplace(owner, [&](auto & entry)
        {
          entry.id = unlocking.available_primary_key();
          entry.unlocked_at = time_point(microseconds(eosio::current_time_point().time_since_epoch()._count + 1000000 * wait*60*60*24));
          entry.quantity = unlock_quantity;
        });
  }
}

void token::convert_locked_to_balance( name owner )
{
  accounts from_acnts( _self, owner.value );
  locked_funds locked( _self, owner.value );
  unlocking_funds unlocking( _self, owner.value );
  
  auto itr = unlocking.begin();
  while(itr != unlocking.end())
  {
    if(itr->unlocked_at > eosio::current_time_point())
    {
      ++itr;
      continue;
    }
    auto acnt_itr = from_acnts.find(itr->quantity.symbol.code().raw());
    check( acnt_itr->locked >= itr->quantity, "Trying to claim more tokens from unlocking than are available in your locked balance. Please contact a member of the Chintai team on Telegram (https://t.me/ChintaiEOS) or by email (hello@chintai.io)." );
    from_acnts.modify(acnt_itr, same_payer, [&](auto & entry)
        {
        entry.locked -= itr->quantity;
        });
    itr = unlocking.erase(itr);
  }
}

void token::sub_balance( name owner, asset value ) {
   accounts from_acnts( _self, owner.value );

   const auto& from = from_acnts.get( value.symbol.code().raw(), "No balance object found, you do not own any CHEX" );
   check( from.balance.amount >= value.amount, "Overdrawn balance, only " + from.balance.to_string() + " is available" );
   check( from.balance - from.locked >= value, "You are attempting to transfer " + value.to_string() + ", but you can only transfer " + (from.balance - from.locked).to_string() + ", because " + from.locked.to_string() + " are in the locked state. You can unlock them using the \"unlock\" action. You must then wait for the tokens to finish unlocking before attempting this action again." );

   from_acnts.modify( from, owner, [&]( auto& a ) {
         a.balance -= value;
      });
}

void token::add_balance( name owner, asset value, name ram_payer )
{
   accounts to_acnts( _self, owner.value );
   auto to = to_acnts.find( value.symbol.code().raw() );
   if( to == to_acnts.end() ) {
      to_acnts.emplace( ram_payer, [&]( auto& a ){
        a.balance = value;
        a.locked.amount = 0;
        a.locked.symbol = value.symbol;
      });
   } else {
      to_acnts.modify( to, same_payer, [&]( auto& a ) {
        a.balance += value;
      });
   }
}

void token::open( name owner, const symbol& symbol, name ram_payer )
{
   require_auth( ram_payer );

   check(is_account(owner), "Can not open a balance for an account that doesn't exist");

   auto sym_code_raw = symbol.code().raw();

   stats statstable( _self, sym_code_raw );
   const auto& st = statstable.get( sym_code_raw, "symbol does not exist" );
   check( st.supply.symbol == symbol, "symbol precision mismatch" );

   accounts acnts( _self, owner.value );
   auto it = acnts.find( sym_code_raw );
   if( it == acnts.end() ) {
      acnts.emplace( ram_payer, [&]( auto& a ){
        a.balance = asset{0, symbol};
        a.locked = asset{0, symbol};
      });
   }
}

void token::close( name owner, const symbol& symbol )
{
   require_auth( owner );
   accounts acnts( _self, owner.value );
   auto it = acnts.find( symbol.code().raw() );
   check( it != acnts.end(), "Balance row already deleted or never existed. Action won't have any effect." );
   check( it->balance.amount == 0, "Cannot close because the balance is not zero." );
   check( it->locked.amount == 0, "Cannot close because the balance is not zero." );
   acnts.erase( it );
}

} /// namespace eosio
