// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./EPlayer.sol";


contract ESeed is EPlayer{
    
    mapping (uint => uint8) public daysToHarvest;

    // constructor() public {
    //     daysToHarvest[0] = 5;
    //     daysToHarvest[1] = 8;
    //     daysToHarvest[2] = 8;
    //     daysToHarvest[3] = 10;
    //     daysToHarvest[4] = 8;
    //     daysToHarvest[5] = 10;
    // }

    constructor() public {
        daysToHarvest[0] = 2;
        daysToHarvest[1] = 2;
        daysToHarvest[2] = 2;
        daysToHarvest[3] = 2;
        daysToHarvest[4] = 2;
        daysToHarvest[5] = 2;
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
        if(seeds.length != 0){
            _createSeed(appendUintToString("Seed ", seeds.length), randTraits);
        } else {
            _createSeed("Seed 0", randTraits);
        }
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

    function getTotalSeeds() external view returns(uint){
        return seeds.length;
    }

    function appendUintToString(string inStr, uint _v) private pure returns (string) {
        uint v = _v;
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        return string(s);
    }

    function createLand(string _name) public{
        uint id = players.push(Player(_name, new uint[](0), 1, block.number)); //- 1
        ownerPlayer[msg.sender] = id;
        createRandomSeed(seeds.length);
    }


    //enum Seasons {SPRING, SUMMER, FALL, WINTER}

    //struct Player {
        //Seasons season; // = Seasons.SPRING;
        //uint8 current_day


    //}


}