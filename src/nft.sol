// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract PatrickInTheGym is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    
    mapping(address => bool) public _minted;
    string public name = "Patrick Through VRF";

    event TokenMinted(address indexed account, uint256 indexed id);

    constructor() ERC1155("ipfs://QmXN7twhiJF7pSttkvqxfok9o5p1QWJeCbwRTZvZ5RCzvz/{id}.json") {}

    function mint(uint256 id)
        public
    {
        require(!_minted[msg.sender], "You can only mint once");
        _minted[msg.sender] = true;
        _mint(msg.sender, id, 1, "");
        emit TokenMinted(msg.sender, id);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}