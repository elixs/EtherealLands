// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./EPlayer.sol";


contract ESeed is EPlayer{
    
    mapping (uint => uint8) public daysToHarvest;

    constructor() public {
        daysToHarvest[0] = 5;
        daysToHarvest[1] = 8;
        daysToHarvest[2] = 8;
        daysToHarvest[3] = 10;
        daysToHarvest[4] = 8;
        daysToHarvest[5] = 10;
    }

    event SeedCreated(
        uint id,
        string name,
        uint traits
    );

    uint seedsTypes = 6;

    uint traitsDigits = 6;
    uint traitsModulus = 10 ** traitsDigits;

    //Traits
    // 3: hue -> 0 to 359, saturation and value are both 1
    // 2: type -> 0 to 5 for now, in order they are Turnip, Potato, Onion, Tomato, Carrot, Eggplant
    // 1: bonus -> -1 to 1

    struct Seed {
        string name;
        uint traits;
        uint8 remainingDays;
        bool isWatered;
    }

    Seed[] public seeds;

    mapping (uint => address) public seedOwner;
    mapping (address => uint) ownedSeedsCount;

    function _createSeed(string _name, uint _traits) private {
        uint id = seeds.push(Seed(_name, _traits, 0, false)) - 1;
        seedOwner[id] = msg.sender;
        ownedSeedsCount[msg.sender] = ownedSeedsCount[msg.sender].add(1);
        emit SeedCreated(id, _name, _traits);
    }

    function _generateRandomTraits(uint _int) private view returns (uint) {
        uint rand = uint(keccak256(abi.encode(_int)));
        return rand % traitsModulus;
    }

    function createRandomSeed(uint _id) public {
        //require(ownedSeedsCount[msg.sender] == 0, "The first seed was already created");
        uint randTraits = _generateRandomTraits(_id);
        _createSeed(strConcat("Seed ",bytes32ToString(bytes32(seeds.length))), randTraits);
    }

    function getType(uint _seedId) public view returns (uint){
        Seed storage seed = seeds[_seedId];
        uint seedType = seed.traits/1000;
        seedType = seedType % 100;
        return seedType % seedsTypes;
    }

    function getBonus(uint _seedId) public view returns (uint){
        Seed storage seed = seeds[_seedId];
        uint seedBonus = seed.traits/100000;
        seedBonus = seedBonus % 10;
        return seedBonus % 3 - 1;
    }

    function bytes32ToString (bytes32 data) private pure returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }

    function strConcat(string _a, string _b) private pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
        return string(bab);
    }


    //enum Seasons {SPRING, SUMMER, FALL, WINTER}

    //struct Player {
        //Seasons season; // = Seasons.SPRING;
        //uint8 current_day


    //}


}