// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./zepplin/ERC20/SafeMath.sol";
import "./zepplin/ERC20/Ownable.sol";
import "./zepplin/ERC20/SafeERC20.sol";
import "./NeopinToken.sol";

contract Lockup is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    address private _npt;
    address private _owner;
    // uint256 private minfoSize = 0; 
    mapping (address => MInfo) private _mapInfo;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event DelMember(address member);
    event AddMember(address member, uint256 paid);
    event UpdateMInfo(address member, uint256 paid);
    event TrsMember(address member, uint256 paid);
    
  	constructor(address cnt) {
		_npt = cnt;
		_owner = msg.sender;
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
        
        // minfoSize ++;
        emit AddMember(member, amount);
    }
    
    function _setPaidBalance(address account, uint256 amount) internal  
        returns (bool) 
        {
        require(isMember(account), "not found member");
        balances[account] = SafeMath.add(balances[account], amount);
        
        emit UpdateMInfo(account, amount);
        return true;
    }
    
    function payableBalance(address account) public view 
        returns (uint256 total) 
        {
        require(isMember(account), "not found member");
        total = SafeMath.sub(_getLimitBalance(account),  balances[account]);
    }
    
    function isMember(address account) public view returns(bool) {
      return _mapInfo[account].status;
    }
    
    function removeMember(address account) external onlyOwner{
        require(isMember(account));
        balances[account] = 0 ;
        allowed[_owner][account] = 0;
        delete _mapInfo[account];
        emit DelMember(account);
    }
    
    function withdraw(uint256 amount) public {
        // require(IERC20(address(this)).allowance(_owner, msg.sender) >= amount, "check the balances") ;
        require(payableBalance(msg.sender) >= amount, "check the balances");
        require(_setPaidBalance(msg.sender, amount), "check the total balances");
        require(IERC20(address(_npt)).transferFrom(_owner, msg.sender, amount));
        emit TrsMember(msg.sender, amount);
    }
}
