// solium-disable linebreak-style
pragma solidity ^0.4.24;

import "./ESleep.sol"; 
import "./ERC721.sol"; 


contract EOwnership is ESleep, ERC721 {

    mapping (uint => address) seedApprovals;
    mapping (address => mapping (address => bool)) internal seedOperatorApprovals;
    
    /**
    * @dev Gets the balance of the specified address
    * @param _owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "The owner address can't be 0x0");
        return ownedSeedsCount[_owner];
    }

    /**
    * @dev Gets the owner of the specified token ID
    * @param _tokenId uint256 ID of the token to query the owner of
    * @return owner address currently marked as the owner of the given token ID
    */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = seedOwner[_tokenId];
        require(owner != address(0), "The owner address can't be 0x0");
        return owner;
    }

    /**
    * @dev Approves another address to transfer the given token ID
    * The zero address indicates there is no approved address.
    * There can only be one approved address per token at a given time.
    * Can only be called by the token owner or an approved operator.
    * @param _to address to be approved for the given token ID
    * @param _tokenId uint256 ID of the token to be approved
    */
    function approve(address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(_to != owner, "Can't approve the same address");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "The sender is neither the owner nor an operator");

        seedApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

    /**
    * @dev Gets the approved address for a token ID, or zero if no address set
    * @param _tokenId uint256 ID of the token to query the approval of
    * @return address currently approved for the given token ID
    */
    function getApproved(uint256 _tokenId) public view returns (address) {
        return seedApprovals[_tokenId];
    }

    /**
    * @dev Sets or unsets the approval of a given operator
    * An operator is allowed to transfer all tokens of the sender on their behalf
    * @param _to operator address to set the approval
    * @param _approved representing the status of the approval to be set
    */
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender, "An address can't be his own operator");
        seedOperatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
    * @dev Tells whether an operator is approved by a given owner
    * @param _owner owner address which you want to query the approval of
    * @param _operator operator address which you want to query the approval of
    * @return bool whether the given operator is approved by the given owner
    */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
        public
        view
        returns (bool)
    {
        return seedOperatorApprovals[_owner][_operator];
    }

    /**
    * @dev Transfers the ownership of a given token ID to another address
    * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
    * Requires the msg sender to be the owner, approved, or operator
    * @param _from current owner of the token
    * @param _to address to receive the ownership of the given token ID
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
        )
        public
        {
        require(isApprovedOrOwner(msg.sender, _tokenId), "The sender is neither the owner nor is approved");
        require(_to != address(0), "The destination address can't be 0x0");

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    /**
    * @dev Returns whether the given spender can transfer a given token ID
    * @param _spender address of the spender to query
    * @param _tokenId uint256 ID of the token to be transferred
    * @return bool whether the msg.sender is approved for the given token ID,
    *  is an operator of the owner, or is the owner of the token
    */
    function isApprovedOrOwner(
        address _spender,
        uint256 _tokenId
    )
        internal
        view
        returns (bool)
    {
        address owner = ownerOf(_tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (
            _spender == owner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(owner, _spender)
        );
    }

    /**
    * @dev Internal function to clear current approval of a given token ID
    * Reverts if the given address is not indeed the owner of the token
    * @param _owner owner of the token
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner, "The given owner doesn't own the seed");
        if (seedApprovals[_tokenId] != address(0)) {
            seedApprovals[_tokenId] = address(0);
        }
    }

    /**
    * @dev Internal function to add a token ID to the list of a given address
    * @param _to address representing the new owner of the given token ID
    * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(seedOwner[_tokenId] == address(0), "The seed has a previous owner");
        seedOwner[_tokenId] = _to;
        ++ownedSeedsCount[_to];
    }

    /**
    * @dev Internal function to remove a token ID from the list of a given address
    * @param _from address representing the previous owner of the given token ID
    * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
    */
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from, "The seed doesn't belong to the give address");
        --ownedSeedsCount[_from];
        seedOwner[_tokenId] = address(0);
    }
}