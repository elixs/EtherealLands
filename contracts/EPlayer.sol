// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./Ownable.sol";

contract EPlayer is Ownable{

    struct Player {
        string name;
        uint[] seedsPlanted;
        uint8 currentDay;
        uint lastBedtime;
        //Add current season
    }

    Player[] players;

    mapping (address => uint) public ownerToPlayer;

    function createLand(string _name) public{
        uint id = players.push(Player(_name, new uint[](0), 1, block.number)); //- 1
        ownerToPlayer[msg.sender] = id;

    }
}