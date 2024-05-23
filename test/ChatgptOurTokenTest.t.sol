// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address public user1 = address(0x1);
    address public user2 = address(0x2);
    uint256 public constant INITIAL_SUPPLY = 200 * 10**18;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
        vm.prank(address(msg.sender));
    }

    function testInitialSupply() view public {
        // vm.prank(msg.sender);
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
        assertEq(ourToken.balanceOf(msg.sender), INITIAL_SUPPLY);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(msg.sender, 1);
    }

    function testAllowance() public {
        // vm.prank(msg.sender);
        // // Initial allowance should be zero
        // assertEq(ourToken.allowance(msg.sender, user1), 0);

        // Approve user1 to spend 100 tokens
        ourToken.approve(user1, 100 * 10**18);
        assertEq(ourToken.allowance(msg.sender, user1), 100 * 10**18);
    }

    function testTransfer() public {
        uint256 amount = 100 * 10**18;

        // Transfer 100 tokens from this contract to user1
        ourToken.transfer(user1, amount);
        assertEq(ourToken.balanceOf(msg.sender), INITIAL_SUPPLY - amount);
        assertEq(ourToken.balanceOf(user1), amount);
    }

    function testTransferFrom() public {
        // vm.prank(msg.sender);
        uint256 amount = 100 * 10**18;

        // Approve user2 to spend 100 tokens on behalf of this contract
        ourToken.approve(user2, amount);

        // Check initial balances
        assertEq(ourToken.balanceOf(msg.sender), INITIAL_SUPPLY);
        // assertEq(ourToken.balanceOf(user1), INITIAL_SUPPLY);
        assertEq(ourToken.allowance(msg.sender, user2), amount);

        // Transfer 100 tokens from this contract to user1 by user2
        vm.prank(user2);
        ourToken.transferFrom(msg.sender, user1, amount);

        // Check final balances
        assertEq(ourToken.balanceOf(msg.sender),
        INITIAL_SUPPLY - amount);
        assertEq(ourToken.balanceOf(user1), amount);
        assertEq(ourToken.allowance(msg.sender, user2), 0);
    }

    function testTransferExceedsBalance() public {
        uint256 amount = INITIAL_SUPPLY + 1;

        // Try to transfer more tokens than available balance
        vm.expectRevert();
        ourToken.transfer(user1, amount);
    }

    function testTransferFromExceedsAllowance() public {
        uint256 allowance = 100 * 10**18;
        uint256 amount = allowance + 1;

        // Approve user2 to spend 100 tokens on behalf of this contract
        ourToken.approve(user2, allowance);

        // Try to transfer more tokens than allowed
        vm.prank(user2);
        vm.expectRevert();
        ourToken.transferFrom(msg.sender, user1, amount);
    }

    function testApproveAndCall() public {
        uint256 amount = 100 * 10**18;

        // Approve user1 to spend 100 tokens
        ourToken.approve(user1, amount);
        assertEq(ourToken.allowance(msg.sender, user1), amount);

        // Call transferFrom by user1 to transfer tokens to user2
        vm.prank(user1);
        ourToken.transferFrom(msg.sender, user2, amount);
        assertEq(ourToken.balanceOf(user2), amount);
        assertEq(ourToken.balanceOf(msg.sender), 100 ether);
        assertEq(ourToken.allowance(msg.sender, user1), 0);
    }
}
