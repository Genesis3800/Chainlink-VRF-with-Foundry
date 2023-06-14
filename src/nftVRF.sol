// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

//Chainlink VRF imports
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract PatrickInTheGym is
    ERC1155,
    ERC1155Burnable,
    Ownable,
    ERC1155Supply,
    VRFConsumerBaseV2
{
    //Contract Variables and events
    mapping(address => bool) public _minted;
    string public name = "Patrick Through VRF";
    mapping(uint256 => address) public _requestIdToMinter;
    event RequestInitalized(uint256 indexed requestId, address indexed minter);
    event NftMinted(uint256 indexed tokenID, address indexed minter);

    //Chainlink Variables
    VRFCoordinatorV2Interface private immutable CoordinatorInterface;
    uint64 private immutable _subscriptionId;
    address private immutable _vrfCoordinatorV2Address;
    bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 callbackGasLimit = 200000;
    uint16 blockConfirmations = 10;
    uint32 numWords = 1;

    constructor(
        uint64 subscriptionId,
        address vrfCoordinatorV2Address
    )
        ERC1155("ipfs://QmXN7twhiJF7pSttkvqxfok9o5p1QWJeCbwRTZvZ5RCzvz/{id}.json")
        VRFConsumerBaseV2(vrfCoordinatorV2Address)
    {
        _subscriptionId = subscriptionId;
        _vrfCoordinatorV2Address= vrfCoordinatorV2Address;
        CoordinatorInterface = VRFCoordinatorV2Interface(vrfCoordinatorV2Address);
    }

    function mint() public returns (uint256 requestId) {
        require(!_minted[msg.sender], "You can only mint once");

        //Calling requestRandomWords from the coordinator contract
        requestId = CoordinatorInterface.requestRandomWords(
            keyHash,
            _subscriptionId,
            blockConfirmations,
            callbackGasLimit,
            numWords
        );

        // map the caller to their respective requestIDs.
        _requestIdToMinter[requestId] = msg.sender;

        // emit an event
        emit RequestInitalized(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        // get the minter address
        address minter = _requestIdToMinter[requestId];

        // To generate a random number between 1 and 100 inclusive
        uint256 randomNumber = (randomWords[0] % 100) + 1;

        uint256 tokenId;

        //manipulate the random number to get the tokenId with a variable probability
        if(randomNumber == 100){
            tokenId = 1;
        } else if(randomNumber % 3 == 0) {
            tokenId = 2;
        } else {
            tokenId = 3;
        }
        
        // Updating the mapping
        _minted[minter] = true;

        // Finally mint the token
        _mint(minter, tokenId, 1, "");

        // emit an event
        emit NftMinted(tokenId, minter);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}