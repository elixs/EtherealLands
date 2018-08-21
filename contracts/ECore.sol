pragma solidity ^0.4.23;

import "./EWater.sol"; 

contract ECore is EWater{

    function goToBed() public{
        uint playerId = ownerToPlayer[msg.sender];
        if(playerId != 0){
            Player storage player = players[playerId];
            uint seedPlantedLength = player.seedsPlanted.length;
            for(uint i = 0; i < seedPlantedLength; ++i){
                Seed storage seed = seeds[player.seedsPlanted[i]];
                if(seed.isWatered){
                    seed.isWatered = false;
                    --seed.remainingDays;
                    if(seed.remainingDays == 0){
                        // Cosecha
                        // Se crea una nueva semilla a partir de la que se cosecho
                        createRandomSeed(seed.traits + block.number);
                        //continue;
                    }

                }
            }
            ++player.currentDay;
        }
    }
}