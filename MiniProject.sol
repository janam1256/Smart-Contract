// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnhancedStore {
    address public owner;
    uint256 public updateFee = 0.01 ether;
    uint256 public lastUpdated;
    bool public isActive = true;

    // Mapping to store data for each user
    mapping(address => string) private userData;

    // Event to log when data is updated
    event DataUpdated(string newData, address updatedBy);

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender; // msg.sender represents the address deploying the contract
    }

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Modifier to ensure the contract is active
    modifier contractIsActive() {
        require(isActive, "The contract is deactivated");
        _;
    }

    // Function to set data for a user, requiring a fee
    function setUserData(string memory _data) public payable contractIsActive {
        require(msg.value == updateFee, "Incorrect fee amount");
        require(bytes(_data).length > 0, "Data cannot be empty");
        require(bytes(_data).length <= 256, "Data too long, must be less than 256 characters");

        userData[msg.sender] = _data;
        lastUpdated = block.timestamp; // Store the current timestamp

        emit DataUpdated(_data, msg.sender); // Emit an event when data is updated
    }

    // Function to get the data for the caller
    function getUserData() public view returns (string memory) {
        return userData[msg.sender];
    }

    // Function to withdraw the contract balance to the owner's address
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to handle direct transfers to the contract
    fallback() external payable {}

    // Receive function to accept Ether directly into the contract
    receive() external payable {}

    // Function to deactivate the contract (only accessible by the owner)
    function deactivateContract() public onlyOwner {
        isActive = false;
    }

    // Function to reactivate the contract (only accessible by the owner)
    function reactivateContract() public onlyOwner {
        isActive = true;
    }
}
