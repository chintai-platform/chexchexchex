# chexchexchex contract

# How to Build
   - cd to 'build' directory
   - run the command 'cmake ..'
   - run the command 'make'

# After build -
   - The built smart contract is under the 'chexchexchex' directory in the 'build' directory
   - You can then do a 'set contract' action with 'cleos' and point in to the './build/chexchexchex' directory
   - Additions to CMake should be done to the CMakeLists.txt in the './src' directory and not in the top level CMakeLists.txt

# How to use
<h2 class="contract"> create </h2>
<h3>Parameters</h3>
- __issuer__
- __maximum_supply__

<h3>Intent</h3>
The intent of `create` is to create a new token with a `maximum_supply} as indicated. The format of the asset must include the correct number of decimal places, and the token symbol. For example, 1000000000.00000000 CHEX will create a supply of 1 billion CHEX tokens, with 8 decimal places of precision.
<h2 class="contract"> issue </h2>
<h3>Parameters</h3>
- __to__ 
- __quantity__
- __memo__

<h3>Intent</h3>
The intent of `issue` is to generate `quantity` new tokens and allocate them to the `to` account. New tokens can not be issued beyond the value of `maximum_supply`. The `memo` can be used to explain why the tokens are being issued.
<h2 class="contract"> retire </h2>
<h3>Parameters</h3>
- __quantity__
- __memo__

<h3>Intent</h3>
The intent of `retire` is to remove `quantity` tokens from circulation. The `memo` can be used to explain why the tokens are being removed.
<h2 class="contract"> transfer </h2>
<h3>Parameters</h3>
- __from__
- __to__
- __quantity__
- __memo__

<h3>Intent</h3>
The intent of `transfer` is to change the ownership of `quantity` tokens from the account `from` to the account `to`. Only unlocked tokens can be transferred. The `memo` can be used to explain why the tokens are being transferred.
<h2 class="contract"> open </h2>
<h3>parameters</h3>
- __owner__
- __symbol__
- __ram_payer__

<h3>Intent</h3>
The intent of `open` is to create a table entry for a token with symbol `symbol` for the `owner`. The {ram_payer} pays the ram for the table entry.
<h2 class="contract"> close </h2>
<h3>parameters</h3>
- __owner__
- __symbol__

<h3>Intent</h3>
The intent of `close` is to delete a table entry for a token with symbol `symbol` for the `owner`. The {ram_payer} will get their RAM back upon success. A table entry for the token data can only be closed if the user has no token balance.
<h2 class="contract"> lock </h2>
<h3>parameters</h3>
- __owner__
- __quantity__
- __days__

<h3>Intent</h3>
The intent of `lock` is to lock `quantity` tokens of `owner` for `days` days. When the tokens are locked, they can not be used. Only when the `unlock` action is called will the timer start for unlocking the locked tokens. You can lock different amounts of tokens for different amounts of time.
<h2 class="contract"> unlock </h2>
<h3>parameters</h3>
- __owner__
- __quantity__

<h3>Intent</h3>
The intent of `unlock` is to move `quantity` locked tokens to the unlocked state, allowing the `owner` to use them. When tokens are unlocked, a timer starts to move them to the unlocked state. The timer takes an amount of time equal to `days`, which was determined when the tokens were locked. The first tokens to unlock are the ones with the shortest locking period.
<h2 class="contract"> burn </h2>
<h3>parameters</h3>
- __owner__
- __quantity__

<h3>Intent</h3>
The intent of `burn` is to permanently destroy `quantity` tokens belonging to `owner`. This will reduce the balance of the `owner` account by `quantity` and it will also reduce the `supply` and `maximum_supply` by the quantity as well.
