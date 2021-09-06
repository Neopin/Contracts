// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../openzeppelin/contracts/math/SafeMath.sol";
import "../openzeppelin/contracts/ownership/Ownable.sol";
import "../openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./NeopinToken.sol";
import "../Role/Member.sol";

contract TokenLock is NPT, Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address private _npt;
    uint256 private minfoSize = 0; 
    mapping (address => MInfo) private _mapInfo;

    event DelMember(address member);
    event AddMember(address member, uint256 paid);
    event UpdateMInfo(address member, uint256 paid);
    
  	constructor(address cnt) {
		_npt = cnt;
  	}
  	
  	struct MInfo {
        uint256 start;
        bool status;
    }
    
    modifier onlyMember() {
        require(isMember(msg.sender), "Role : msg sender is not momber");
        _;
    }

    function _getLimitBalance(address member) internal view returns(uint256 res){
        require(isMember(member), "not found member");
        uint256 curTime = block.timestamp;
        
        MInfo memory _info = _mapInfo[member];
        uint256 init = _info.start;
        uint256 total = allowed[_owner][member];
        
 
        if (init + ( 1260 * 1 days ) < curTime)
            res = total * 20/20;
        else if(init + ( 990 * 1 days ) < curTime)
            res = total * 14/20;
        else if(init + ( 720 * 1 days ) < curTime)
            res = total * 9/20;
        else if(init + ( 450 * 1 days ) < curTime)
            res = total * 4/20;
        else if(init + ( 270 * 1 days ) < curTime)
            res = total * 2/20;
        else if (init + (90 * 1 days ) < curTime)
            res = total * 1/20;    
        else
            res = 0;
    }

    function setMember(address member, uint256 mstart, uint256 amount) external onlyOwner {
        require(!isMember(member), "already join member");
        require(amount > 0, "fail amount limit");

        allowed[msg.sender][member] = amount * 1e18;
        balances[member] = 0;
        
        _mapInfo[member] = MInfo({
            start : mstart,
            status : true
        });
        
        minfoSize ++;
        emit AddMember(member, amount);
    }
    
    function _setPaidBalance(address account, uint256 amount) internal  
        returns (bool) 
        {
        require(isMember(account), "not found member");
        balances[account] = amount;
        
        emit UpdateMInfo(account, amount);
        return true;
    }
    
    function _getPayableBalance(address account) internal view 
        returns (uint256 total) 
        {
        require(isMember(account), "not found member");
        total = SafeMath.sub(_getLimitBalance(account),  balances[account]);
    }
    
    function isMember(address account) internal view returns(bool) {
      return _mapInfo[account].status;
    }
    
    function getTotalBalance() public view returns(uint256 blc) {
        require(isMember(msg.sender), "not found member");
        blc = IERC20(address(this)).allowance(_owner, msg.sender);
    }
    
    function removeMember(address account) public onlyOwner{
        require(isMember(account));
        require(IERC20(address(this)).allowance(_owner, account) >= 0, "check the balances") ;

        delete _mapInfo[account];
        minfoSize --;
        emit DelMember(account);
    }
    
    function withdraw(uint256 amount) public payable{
        require(IERC20(address(this)).allowance(_owner, msg.sender) >= amount, "check the balances") ;
        require(_setPaidBalance(msg.sender, amount));
        require(IERC20(address(this)).transferFrom(_owner, msg.sender, amount));
        emit Transfer(_owner, msg.sender, amount);
    }
}

