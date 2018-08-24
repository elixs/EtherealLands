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

    Player[] public players;

    mapping (address => uint) public ownerPlayer;
}