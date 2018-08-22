// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./EWater.sol"; 

contract EHelper is EWater{

    function getSeedsByOwner(address _owner) external view returns(uint[]) {
        uint[] memory result = new uint[](ownerSeedCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < seeds.length; i++) {
            if (seedToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    // This is a non secure function to obtain a random number, delete if not used
    uint randNonce = 0;
    function randMod(uint _modulus) internal returns(uint) {
        randNonce++;
        return uint(keccak256(abi.encodePacked(block.number, msg.sender, randNonce))) % _modulus;
    }
}