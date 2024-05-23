// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

contract ManualToken {
    // string public name = "Manual Token";

    mapping(address => uint256) private s_balanceOf;

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return s_balanceOf[_owner];
    }

    function transfer(address _to, uint256 _amount) public {
        require(s_balanceOf[msg.sender] > 0);
        uint256 previousBalance = s_balanceOf[msg.sender] + s_balanceOf[_to];
        s_balanceOf[msg.sender] -= _amount;
        s_balanceOf[_to] += _amount;
        require(previousBalance == s_balanceOf[msg.sender] + s_balanceOf[_to]);
    }
}
