// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./ESeed.sol";

contract EWater is ESeed{

    mapping (address => uint) ownerSeedsPlanted;

    function seedPlanting(uint _seedId) public{
        require(seedToOwner[_seedId] == msg.sender, "The seed doesn't belong to the player");
        Seed storage seed = seeds[_seedId];
        if(seed.remainingDays == 0){
            Player storage player = players[ownerToPlayer[msg.sender]];
            seed.remainingDays = daysToHarvest[getType(_seedId)] + uint8(getBonus(_seedId));
            //seed.lastWatered = player.currentDay;
            player.seedsPlanted.push(_seedId);

        }
    }

    function seedWatering(uint _seedId) public{
        require(seedToOwner[_seedId] == msg.sender, "The seed doesn't belong to the player");
        Seed storage seed = seeds[_seedId];
        //Player storage player = players[ownerToPlayer[msg.sender]];
        if (!seed.isWatered && seed.remainingDays != 0){
            seed.isWatered = true;
            //seed.lastWatered = player.currentDay;
            //--seed.remainingDays;
        }
    }
}