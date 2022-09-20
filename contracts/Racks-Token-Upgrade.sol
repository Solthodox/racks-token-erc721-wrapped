// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract RacksTokenUpgrade is ERC20, ERC721Holder {
    IERC721Enumerable public inmutable UNDERLYING_NFT; // The asset that allow minting
    uint256 public inmutable MAX_MINT; // max mint per call

    uint256 private _minteableSupply; // inexistant supply to be minted
    uint256 private _nftDenominator; // starting denominator to calculate tokens per NFT holder = _minteableSupply/_nftDenominator
    mapping(uint256 => address) private _nftBalances; // tracks the owners of the deposited NFTs

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint256 _minteable_supply,
        uint256 _max_mint,
        address _nftAddress
    ) ERC20(_name, _symbol) {
        _minteableSupply = _minteable_supply;
        _mint(msg.sender, _totalSupply);
        UNDERLYING_NFT = IERC721Enumerable(_nftAddress);
        _nftDenominator = UNDERLYING_NFT.totalSupply();
        MAX_MINT = _max_mint;
    }

    //GETTERS
    function minteableSupply() public view returns (uint256) {
        return _minteableSupply;
    }

    function nftBalance() public view returns (uint256) {
        // we have to substract the initial denominator
        return _nftDenominator - UNDERLYING_NFT.totalSupply();
    }

    ///

    /**
    @notice Deposit NFTs and get new minted tokens
    @param account : tokens receiver
    @param ids : ids of NFTs to be deposited
    @param minTokens: minimum amount of expected tokens to be minted.
    If doesn't fulfill the order, reverts

     */

    function depositFor(
        address account,
        uint256[] calldata ids,
        uint256 minTokens
    ) public returns (bool) {
        require(_mintWrapped(account, ids) >= minTokens, "Tokens < minTokens");
        return true;
    }

    /**
    @notice Deposit tokens and get deposited NFTs back
    @param account : NFTs receiver
    @param ids : ids of NFTs to be withdrawn
    @param minTokens: minimum amount of NFTs to get back.
    If doesn't fulfill the order, reverts
     */

    function withdrawTo(
        address account,
        uint256 amount,
        uint256[] calldata ids,
        uint256 minNfts
    ) public returns (bool) {
        require(
            _burnWrapped(account, amount, ids) >= minNfts,
            "Nfts < minNfts"
        );
        return true;
    }
    /**
    @notice Returns the token amount you get back for a number of
    NFTs at a certain moment.
     */
    function simulateDeposit(uint256 nftAmount)
        public
        view
        returns (uint256 tokenAmount)
    {
        tokenAmount =
            (_minteableSupply * nftAmount) /
            (_nftDenominator + nftAmount);
    }

    /**
    @notice Returns the token NFTs you get back for a number of
    tokens at a certain moment.
     */
    function simulateWithdraw(uint256 tokenAmount)
        public
        view
        returns (uint256 nftAmount)
    {
        nftAmount =
            (_nftDenominator * tokenAmount) /
            (_minteableSupply + tokenAmount);
    }
    /**
    @notice Returns the token input needed to withdraw a certain amount of NFTs
     */
    function calculateWithdrawalCost(uint256 nftAmount) public view returns(uint256 tokenCost){
        tokenCost = (_minteableSupply * nftAmount) / (_nftDenominator - nftAmount);
    }
    /**
    * @dev Mint some tokens using NFTs:
        -Transfer all the assets to the contract , save the id's owner in _nftBalances
        - Calculates token amount to get using the constant product invariant(simulateDeposit):
            x * y = k
            (x + dx) * y = k
            y' = k / (x + dx)
            dy = y - y'
        - If the amount calculated is > MAX_MINT reverts
        -Mint the tokens
        -Update "balances"
    * @return true
     */
    function _mintWrapped(address _account, uint256[] calldata _ids)
        private
        returns (uint256 amount)
    {
        uint256 len = _ids.length;
        require(len > 0, "ERROR: Empty array");
        for (uint256 i = 0; i < len; ) {
            uint256 id = _ids[i];
            UNDERLYING_NFT.transferFrom(msg.sender, address(this), id);
            _nftBalances[id] = msg.sender;
            unchecked {
                ++i;
            }
        }
        amount = simulateDeposit(len);
        require(amount <= MAX_MINT, "Amount > MAX_MINT");
        _mint(_account, amount);
        _update(_minteableSupply - amount, _nftDenominator + len);
    }
    /**
    *@dev Burn the previously minted tokens and get deposited NFTs back:
        -Burn tokens
        -Calculate NFT amount
        - Loop through provided Ids and transfer to owner
        - Update "balances"
    @return true
     */
    function _burnWrapped(
        address _account,
        uint256 _amount,
        uint256[] calldata _ids
    ) private returns (uint256) {
        _burn(msg.sender, _amount);
        uint256 nftAmount = simulateWithdraw(_amount);
        uint256 amountOut;
        uint256 len = _ids.length;
        require(len > 0, "ERROR: Empty array");
        for (uint256 i = 0; i < len; ) {
            uint256 id = _ids[i];
            if (_nftBalances[id] == msg.sender) {
                delete _nftBalances[id];
                UNDERLYING_NFT.safeTransferFrom(address(this), _account, id);
                amountOut++;
            }
            if (amountOut >= nftAmount) break;
            unchecked {
                ++i;
            }
        }
        _update(_minteableSupply + _amount, _nftDenominator - len);
        return amountOut;
    }

    /**
    @dev Updates the balances of its asset after each operation
     */
    function _update(uint256 b0, uint256 b1) private {
        _minteableSupply = b0;
        _nftDenominator = b1;
    }
}
