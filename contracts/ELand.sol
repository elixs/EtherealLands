pragma solidity ^0.4.23;

/** @title Ethereal Land. */
contract ELand {
    event SeedCreated(
        uint id,
        string name,
        uint traits
    );


    uint traitsDigits = 16;
    uint traitsModulus = 10 ** traitsDigits;

    struct Seed {
        string name;
        uint traits; //tipo , color, cantidad de dias necesarios para que creza, depende del tipo
    }

    Seed[] public seeds;

    function _createSeed(string _name, uint _traits) private {
        uint id = seeds.push(Seed(_name, _traits)) - 1;
        emit SeedCreated(id, _name, _traits);
    }

    function _generateRandomTraits(string _str) private view returns (uint) {
        uint rand = uint(keccak256(bytes(_str)));
        return rand % traitsModulus;
    }

    function createRandomSeed(string _name) public {
        uint randTraits = _generateRandomTraits(_name);
        _createSeed(_name, randTraits);
    }


    //enum Seasons {SPRING, SUMMER, FALL, WINTER}

    //struct Player {
        //Seasons season; // = Seasons.SPRING;
        //uint8 current_day


    //}


}