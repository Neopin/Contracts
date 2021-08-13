// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

import "../openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract NPT is ERC20 {
    using SafeERC20 for IERC20;

    constructor() ERC20("NEOPIN Token", "NPT") {
        _mint(msg.sender, 1000000000e18);
    }

    // added Function
    function increaseAllowance(address _spender, uint256 _addedValue)
        external
        override
        returns (bool)
    {
        IERC20 token = IERC20(address(this));
        token.safeIncreaseAllowance(_spender, _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        external
        override
        returns (bool)
    {
        IERC20 token = IERC20(address(this));
        token.safeDecreaseAllowance(_spender, _subtractedValue);
        return true;
    }

    function burn(uint256 _amount) external returns (bool) {
        _burn(msg.sender, _amount);
        return true;
    }
}
