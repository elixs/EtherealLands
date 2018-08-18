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
                    if(seed.remainingDays == 0){
                        // Cosecha
                        // Ahora se está creando la aleatoridad a partir del nombre, hay que pensar en una mejor manera, a partir del lenght de seeds los más probable
                        createRandomSeed(bytes32ToString(bytes32(seed.traits)));
                        //continue;
                    }
                    else{
                        --seed.remainingDays;
                    }

                }
            }
        }
    }
}