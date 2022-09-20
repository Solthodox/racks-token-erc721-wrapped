// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC271/extentions/ERC721Enumerable.sol";

contract MrCryptoMock is ERC721Enumarable {
    constructor() ERC271("MrCrypto ...", "MRC") {}

    function mint(address receiver, uint256 id) public {
        _mint(receiver, id);
    }
}
