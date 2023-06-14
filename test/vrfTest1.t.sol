// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/nftVRF.sol";
import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract PatrickInTheGymTest is Test {

    //Creating instances of the main contract
    //and the mock contract
    PatrickInTheGym public patrickInTheGym;
    VRFCoordinatorV2Mock public mock;

    //To keep track of the number of NFTs
    //of each tokenID
    mapping(uint256 => uint256) supplytracker;
    
    //This is a shorthand used to represent the full address
    // address(1) == 0x0000000000000000000000000000000000000001
    address alpha = address(1);

    function setUp() public {
        mock = new VRFCoordinatorV2Mock(100000000000000000, 1000000000);

        //Creating a new subscription through account 0x1
        //Using the Prank cheatcode
        vm.prank(alpha);
        uint64 subId = mock.createSubscription();

        //funding the subscription with 1000 LINK
        mock.fundSubscription(subId, 1000000000000000000000);

        //Creating a new instance of the main consumer contract
        patrickInTheGym = new PatrickInTheGym(subId, address(mock));

        //Adding the consumer contract to the subscription
        //Only owner of subscription can add consumers
        vm.prank(alpha);
        mock.addConsumer(subId, address(patrickInTheGym));
    }

    function testRandomness() public {

        for (uint i = 1; i <= 1000; i++) {

        //Creating a random address using the 
        //variable {i}
        //Useful to call the mint function from a 100
        //different addresses
        address addr = address(bytes20(uint160(i)));
        vm.prank(addr);
        uint requestID = patrickInTheGym.mint();

        //Have to impersonate the VRFCoordinatorV2Mock contract
        //since only the VRFCoordinatorV2Mock contract 
        //can call the fulfillRandomWords function
        vm.prank(address(mock));
        mock.fulfillRandomWords(requestID,address(patrickInTheGym));
        }

        supplytracker[1] = patrickInTheGym.totalSupply(1);
        supplytracker[2] = patrickInTheGym.totalSupply(2);
        supplytracker[3] = patrickInTheGym.totalSupply(3);

        console2.log("Supply with tokenID 1 is " , supplytracker[1]);
        console2.log("Supply with tokenID 2 is " , supplytracker[2]);
        console2.log("Supply with tokenID 3 is " , supplytracker[3]);

    }
}