// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract RacksTokenUpgrade is ERC20, ERC721Holder {

    IERC721 public inmutable UNDERLYING_NFT;
    uint256 public inmutable MAX_MINT;

    uint526 private _minteableSupply;
    uint256 private _nftDenominator;
    mapping(uint256 => address) private _nftBalances;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _nftAddress,
        uint256 _minteableSupply
    ) ERC20(_name, _symbol) {
        _minteableSupply = _minteableSupply;
        _mint(msg.sender, _totalSupply);
        UNDERLYING_NFT = IERC721(_nftAddress);
        _nftDenominator = UNDERLAYING_NFT.totalSupply();
    }


    function depositFor (
        address account, 
        uint256[] calldata ids, 
        uint256 minTokens
        ) 
        public returns (bool)
    {
        require(_mintWrapped(account , ids)>=minTokens , "Tokens < minTokens");
        return true;
    }

    function withdrawTo(
        address account, 
        uint256 amount,
        uint256[] calldata ids, 
        uint256 minNfts) 
        public returns (bool) 
    {
        require(_burnWrapped(account , ids)>=minTokens , "Tokens < minTokens");
        return true;
    }

    function simulateDeposit(uint256 nftAmount) public view returns(uint256 tokenAmount){
        tokenAmount = (_minteableSupply * nftAmount) / (_nftDenominator + nftAmount);
    }

    function simulateWithdraw (uint256 tokenAmount) public view returns(uint256 nftAmount){
        nftAmount = (_nftDenominator * tokenAmount) / ( _minteableSupply + tokenAmount);
    }

    function _mintWrapped(address _account , uint256[] calldata _ids) private returns(uint256 amount){
        uint256 len = _ids.length;
        require(len>0, "ERROR: Empty array");
         for(uint256 i=0; i<len;){
            uint256 id = _ids[i];
            UNDERLYING_NFT.transferFrom(msg.sender , address(this) , id);
            _nftBalances[id] = msg.sender;
            unchecked {
                ++i;
            }
        }
        amount = simulateDeposit(len);
        require(amount <= MAX_MINT , "Amount > MAX_MINT");  
        _mint(account, amount);
        _update(
            _mintebleSupply - amount, 
            _nftDenominator + len
        );

    }

    function _burnWrapped(address _account, uint256 _amount, uint256[] calldata _ids) private returns(uint256){
        _burn(msg.sender , _amount);
        uint nftAmount = simulateWithdraw(_amount);
        uint256 amountOut;
        uint256 len = _ids.length;
        require(len>0, "ERROR: Empty array");
        for(uint256 i=0; i<len;){
            uint256 id = _ids[i];
            if(_nftBalances[id] = msg.sender){
                delete _nftBalances[id];
                UNDERLYING_NFT.safeTransferFrom(address(this), _account , id);
                amountOut++;
            }
            if (amountOut>=nftAmount) break;
        }
        _update(
            _mintebleSupply + _amount, 
            _nftDenominator - len
        );
        return amountOutM
    }

    function _update(uint256 b0, uint256 b1) private{
        _minteableSupply = b0;
        _nftDenominator = b1;
    }

}
