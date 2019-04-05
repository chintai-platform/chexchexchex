<h1 class="contract"> create </h1>
**Parameters**
* __issuer__
* __maximum_supply__

**Intent**
The intent of {{create}} is to create a new token with a {{maximum_supply} as indicated. The format of the asset must include the correct number of decimal places, and the token symbol. For example, 1000000000.00000000 CHEX will create a supply of 1 billion CHEX tokens, with 8 decimal places of precision.
<h1 class="contract"> issue </h1>
**Parameters**
* __to__ 
* __quantity__
* __memo__

**Intent**
The intent of {{issue}} is to generate {{quantity}} new tokens and allocate them to the {{to}} account. New tokens can not be issued beyond the value of {{maximum_supply}}. The {{memo}} can be used to explain why the tokens are being issued.
<h1 class="contract"> retire </h1>
**Parameters**
* __quantity__
* __memo__

**Intent**
The intent of {{retire}} is to remove {{quantity}} tokens from circulation. The {{memo}} can be used to explain why the tokens are being removed.
<h1 class="contract"> transfer </h1>
**Parameters**
* __from__
* __to__
* __quantity__
* __memo__

**Intent**
The intent of {{transfer}} is to change the ownership of {{quantity}} tokens from the account {{from}} to the account {{to}}. Only unlocked tokens can be transferred. The {{memo}} can be used to explain why the tokens are being transferred.
<h1 class="contract"> open </h1>
**parameters**
* __owner__
* __symbol__
* __ram_payer__

**Intent**
The intent of {{open}} is to create a table entry for a token with symbol {{symbol}} for the {{owner}}. The {ram_payer} pays the ram for the table entry.
<h1 class="contract"> close </h1>
**parameters**
* __owner__
* __symbol__

**Intent**
The intent of {{close}} is to delete a table entry for a token with symbol {{symbol}} for the {{owner}}. The {ram_payer} will get their RAM back upon success. A table entry for the token data can only be closed if the user has no token balance.
<h1 class="contract"> lock </h1>
**parameters**
* __owner__
* __quantity__
* __days__

**Intent**
The intent of {{lock}} is to lock {{quantity}} tokens of {{owner}} for {{days}} days. When the tokens are locked, they can not be used. Only when the {{unlock}} action is called will the timer start for unlocking the locked tokens. You can lock different amounts of tokens for different amounts of time.
<h1 class="contract"> unlock </h1>
**parameters**
* __owner__
* __quantity__

**Intent**
The intent of {{unlock}} is to move {{quantity}} locked tokens to the unlocked state, allowing the {{owner}} to use them. When tokens are unlocked, a timer starts to move them to the unlocked state. The timer takes an amount of time equal to {{days}}, which was determined when the tokens were locked. The first tokens to unlock are the ones with the shortest locking period.
<h1 class="contract"> burn </h1>
**parameters**
* __owner__
* __quantity__

**Intent**
The intent of {{burn}} is to permanently destroy {{quantity}} tokens belonging to {{owner}}. This will reduce the balance of the {{owner}} account by {{quantity}} and it will also reduce the {{supply}} and {{maximum_supply}} by the quantity as well.
