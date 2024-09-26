// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

contract Basic_Solidity {

  // ERC20
  string public constant name = "Fund_Management";
  string public constant symbol = "CF";
  uint8 public constant decimals = 18;

  // Keep track of data needed for ERC20 functions
  address payable public owner;
  mapping (address => uint256) public balances;
  mapping(address => mapping (address => uint256)) public allowed;
  uint256 public _totalSupply; // avoid conflict with totalSupply() ERC20 function
  uint256 public presaleEnd;
  uint256 public lastWithdraw;

  constructor()  payable {
    owner = payable(msg.sender);
    balances[msg.sender] = msg.value;
    _totalSupply = msg.value;
    presaleEnd = block.timestamp + (3 days);
  }

  function withdraw(uint256 amount) public {
    // Don't allow withdrawals unless the following conditions are met
    require(block.timestamp >= presaleEnd);
    require(msg.sender == owner);
    require(amount != 0 && amount <= address(this).balance);
    require(block.timestamp >= lastWithdraw + (7 days));
    require(_totalSupply - address(this).balance + (1 ether) >= amount);

    // Send funds and update last withdraw time
    owner.transfer(amount);
    lastWithdraw = block.timestamp;
  }

  receive() external payable {
    require (block.timestamp < presaleEnd);
    balances[msg.sender] += msg.value;
    _totalSupply += msg.value;
  }

  // ERC20 functions

  function totalSupply() public view returns (uint) {
    return _totalSupply  - balances[address(0)];
  }
  
  function getBalance() public view returns (uint) {
    return address(this).balance;
  }

  function balanceOf(address _owner) public view returns (uint256) {
     return balances[_owner];
  }

  function transfer(address _to, uint256 _amount) public returns (bool) {
    if (block.timestamp < presaleEnd || balances[msg.sender] < _amount
        || _amount == 0) {
      return false;
    }

    balances[msg.sender] -= _amount;
    balances[_to] += _amount;
    return true;
  }

  function transferFrom(address _from, address _to,
                        uint256 _amount) public returns (bool) {
    if (block.timestamp < presaleEnd || allowed[_from][msg.sender] < _amount
        || balances[_from] < _amount || _amount == 0) {
      return false;
    }
    balances[_from] -= _amount;
    allowed[_from][msg.sender] -= _amount;
    balances[_to] += _amount;
    return true;
  }

  function approve(address _spender,
                   uint256 _amount) public returns (bool) {
    allowed[msg.sender][_spender] = _amount;
    return true;
  }
}