// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    enum State {
        Active,
        Failed,
        Successful
    }
    State public state;

    address public immutable creator;
    uint public immutable goal;
    uint public immutable deadline;
    uint public totalRaised;
    bool public totalWithdrawn;

    mapping(address => uint) public contributions;

    constructor(uint _goal, uint _duration) {
        require(_goal > 0, "Invalid goal");
        require(_duration > 0, "Invalid duration");

        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;

        state = State.Active;
    }

    function contribute() external payable {
        require(state == State.Active, "Not active");
        require(block.timestamp < deadline, "Deadline passed");
        require(msg.value > 0, "Invalid amount");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;
    }

    function finalize() external {
        require(state == State.Active, "Not active");
        require(block.timestamp >= deadline, "Deadline not passed");

        if (totalRaised >= goal) {
            state = State.Successful;
        } else {
            state = State.Failed;
        }
    }

    function withdraw() external payable {
        require(state == State.Successful, "State Failed");
        require(msg.sender == creator, "Only creator allowed");
        require(!totalWithdrawn, "already withdrawal done");

        totalWithdrawn = true;

        (bool ok, ) = creator.call{value: address(this).balance}("");
        require(ok, "payment failed");
    }

    function refund() external {
        require(state == State.Failed, "Need to be failed");

        uint amount = contributions[msg.sender];
        require(amount > 0, "nothing to withdraw");

        contributions[msg.sender] = 0;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transaction failed");
    }
}
