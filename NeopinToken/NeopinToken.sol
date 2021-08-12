// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "../openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NPT is ERC20 {
    constructor() ERC20("NEOPIN Token", "NPT") {
        _mint(msg.sender, 1000000000e18);
    }

    function burn(uint256 _amount) public returns (bool) {
        _burn(msg.sender, _amount);
        return true;
    }
}
