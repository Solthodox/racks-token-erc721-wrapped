// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC271/extentions/ERC721Enumerable.sol";

contract MrCryptoMock is ERC721Enumarable {
    constructor() ERC721("MrCrypto ...", "MRC") {}

    function mint(address receiver, uint256 id) public {
        _mint(receiver, id);
    }
}
