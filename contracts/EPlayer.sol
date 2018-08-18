pragma solidity ^0.4.23;

contract EPlayer {

    struct Player {
        string name;
        uint[] seedsPlanted;
        uint8 currentDay;
        //Add current season
    }

    Player[] players;

    mapping (address => uint) public ownerToPlayer;

    function createLand(string _name) public{
        uint id = players.push(Player(_name, new uint[](0), 1)); //- 1
        ownerToPlayer[msg.sender] = id;

    }
}