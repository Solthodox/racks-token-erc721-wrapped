// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
pragma solidity ^0.8.17;

contract MrCryptoMock is ERC721Enumerable {
    constructor() ERC721("MrCrypto ...", "MRC") {}

    function mint(address receiver, uint256 id) public {
        _mint(receiver, id);
    }
}
