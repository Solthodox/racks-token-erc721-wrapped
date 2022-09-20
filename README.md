# ERC721 Wrapped Racks Token

This is a token wrap ERC20 variation. It allows to mint tokens using NFTs instead of another tokens. This could be an interesting proposal for the upcoming Racks Token, since it has a strong community built around the MrCrypto NFT collection.

## General overview

It consists in a regular ERC20 token with some added extra funtionalities , only for the collection hodlers. The token will allow NFT holders to deposit their NFTs in the contract and mint a certain amount of tokens, and burn the tokens to get their NFTs back when needed, a very powerful tool for the hodlers .This means that the token's total supply will not be completely fixed. There is a small portion of the total supply that will be irregular.
  
 ## Technical overview
 
 There is a clear draback in all this: Inflation. How we prevent users from abusing this new functionality and printing too much tokens? Well  this can be fixed using a constant product invariant that will cause slippage, making increasingly more expensive to mint new tokens. We start with this numbers , giving them an initial value to be more explainatory:
 ```
  uint256 private _minteableSupply = 1000000; // the extra tokens to be minted apart from the current supply
  uint256 private _nftDenominator = 10000; // the total supply of the NFT collection
 ```
 Having this, we assume that there is a token amount to be minted per hodler : the minteable supply/ NFT denominator.
 
 ```
  tokensPerUser = 100
 ```
 As mentioned above, this works using a product invariant that we are going to call k:
 ```
  x * y = k
  10000 * 1000000 = 10 ** 10 // 10^10
 ```
 So if a little hodler wants to mint some NFTs, the slippage will be almost 0 for him, lets say he deposits 3 NFTs in the very beginning: 
 
 ```
  dx = 2 // dx = amount in
  
  (x + dx) * y' = k
  (10000 + 2) * y' = 10 ** 10
  y'= 999800.004
  
  dy = y - y' // dy = amount out
  dy = 1000000 - 999800.04
  dy = 199.96
  
 ```
 
 As we can see, the user got 199.6/2 = 99.98 tokens per NFT which is very approximate to the 100 theorical tokens.
 
But if we calculate the most extreme case, where a user owns all the 10000 MrCrypto, this is what he would get : 500000 tokens, which equals to 50 tokens per NFT. This  is a half of what the first user got, which means he will pay a exorbitant price for causing inflation in the token, and even having used all the NFTs, he only got half of the minteable supply. Anyways, as the token starts to be overminted, the hodlers will start to withdraw their NFTs as it becomes simultanously cheaper, even making litle profits, causing a deflationary pressure. This makes the system work similar to how a market maker does.
 
 
 
 ## Benefits

This implementation aims to add more value to the community and the token itself. This are some of the benefits:

  * Diamond hands💎: Users wont't need to lose their positions in their crypto investments to aquire the token: No need to buy other tokens, no need to sell their NFT; just mint it directly from the contract.
  
  * Back MrCrypto with more value: This will undoubtedly give a extra advantage to the hodlers in the defi markets, as having one NFT means instantly having access to a certain amount of tokens and if the token grows it simultaneously adds value to the collection. 
  
  * Innovation⭐: This will add extra value to the token itself.
  
  * Insignificant slippage✅: For most users, it will insignificant since they are little hodlers.
  
  
