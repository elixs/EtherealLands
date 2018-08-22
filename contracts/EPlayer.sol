// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";


contract EPlayer is Ownable{

    using SafeMath for uint256;

    struct Player {
        string name;
        uint[] seedsPlanted;
        uint currentDay;
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