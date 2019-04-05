<h1 class="contract"> create </h1>
**Parameters**
* __issuer__ is of type eosio::name and is the name of the account that issues the token
* __maximum_supply__ is of type eosio::asset and is the maximum amount of tokens that may be issued

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
The intent of {{open}} is to create a table entry for a token with symbol {{symbol}} for the {{owner}}. The 
<h1 class="contract"> close </h1>
**parameters**
* __owner__
* __symbol__

**Intent**
<h1 class="contract"> lock </h1>
**parameters**
* __owner__
* __quantity__
* __days__

**Intent**
<h1 class="contract"> unlock </h1>
**parameters**
* __owner__
* __quantity__

**Intent**
<h1 class="contract"> burn </h1>
**parameters**
* __owner__
* __quantity__

**Intent**
