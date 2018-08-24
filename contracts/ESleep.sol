// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./EHelper.sol";


contract ESleep is EHelper{

    uint sleepFee = 0.001 ether;

    function withdraw() external onlyOwner{
        owner.transfer(address(this).balance);
    }

    function setSleepFee(uint _fee) external onlyOwner {
        sleepFee = _fee;
    }

    function goToBed() public{
        _goToBedLogic(false);
    }

    function goToBedEarlier() external payable{
        require(msg.value == sleepFee, "The ether sent isn't enough");
        _goToBedLogic(true);
    }

    function _goToBedLogic(bool _hasPaid) private{
        uint playerId = ownerPlayer[msg.sender];
        if(playerId != 0){
            Player storage player = players[playerId - 1];
            if(!_hasPaid){
                require(_isReadyToSleep(player), "Hasn't pass enough time to go to bed");
            }
            _triggerSleepCooldown(player);
            //uint seedPlantedLength = player.seedsPlanted.length;
            //uint[] memory seedsGrown = new uint[](seedPlantedLength);
            for(uint i = 0; i < player.seedsPlanted.length; ++i){
                Seed storage seed = seeds[player.seedsPlanted[i]];
                if(seed.isWatered){
                    seed.isWatered = false;
                    --seed.remainingDays;
                    if(seed.remainingDays == 0){
                        // Cosecha
                        // Esto cambio el tamaño arreglo que está iterando el for, ver si es un problema
                        player.seedsPlanted[i] = player.seedsPlanted[player.seedsPlanted.length - 1];
                        delete player.seedsPlanted[player.seedsPlanted.length - 1];
                        // Se crea una nueva semilla a partir de la que se cosecho
                        createRandomSeed(seed.traits + ownedSeedsCount[msg.sender]);
                        //continue;
                    }

                }
            }
            player.currentDay = player.currentDay.add(1);
        }
    }

    
    uint sleepCooldownTime = 216000;

    function _triggerSleepCooldown(Player storage _player) internal {
        _player.lastBedtime = block.number;
    }

    function _isReadyToSleep(Player storage _player) internal view returns (bool) {
        return(block.number - _player.lastBedtime >= sleepCooldownTime);
    }


}