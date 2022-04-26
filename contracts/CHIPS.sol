// contracts/CHIPS.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract CHIPS is Initializable, ERC20Upgradeable, OwnableUpgradeable{
    using SafeMathUpgradeable for uint256;  
    uint256 public constant TOTAL_SUPPLY = 100000000;
    address private teamAddress;
    address private treasuryAddress;
    address private stakeRewardAddress;
    bool public isDistributed;

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "CHIPS :: Cannot be called by a contract");
        _;
    }

    function initialize() external initializer{
        __ERC20_init("CHIPS", "$CHIPS");
        __Ownable_init();
    }

     function distribute() external onlyOwner{
        require(!(isDistributed), "CHIPS :: Already distributed");
        require(teamAddress != address(0), "CHIPS: cannot mint to the zero team address");
        require(treasuryAddress != address(0), "CHIPS: cannot mint to the zero treasury address");
        require(stakeRewardAddress != address(0), "CHIPS: cannot mint to the zero stakeReward address");

        _mint(teamAddress, (TOTAL_SUPPLY.mul(100).div(1000)) * 10 ** decimals());           // Team => 10%
        _mint(treasuryAddress, (TOTAL_SUPPLY.mul(205).div(1000)) * 10 ** decimals() );      // Treasury => 20.5%
        _mint(msg.sender, (TOTAL_SUPPLY.mul(15).div(1000)) * 10 ** decimals());             // Initial Liquidity => 1.5%
        _mint(stakeRewardAddress, (TOTAL_SUPPLY.mul(680).div(1000)) * 10 ** decimals());    // Staking Pool Rewards  => 68%

      

        toggleDistribute();
    }

    function toggleDistribute() internal{
        isDistributed = !isDistributed;
    }

    function buyBack(uint256 amount) public onlyOwner {
        require(balanceOf(msg.sender) >= amount, "You have insufficient CHIPS");
        // add to LP (Liquidity Pool) //40% Locking Liquidity 
        transfer(stakeRewardAddress, (amount.mul(300).div(1000)) ); // 30% Staking Rewards Pool
        burn(msg.sender, (amount.mul(300).div(1000)) );  // 30% Token Burning
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
           
    function setTeamAddress(address _teamAddress) external onlyOwner{
        teamAddress = _teamAddress;
    }
    
    function getTeamAddress() external view onlyOwner returns (address){
        return teamAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyOwner{
        treasuryAddress = _treasuryAddress;
    }

    function getTreasuryAddress() external view onlyOwner returns (address){
        return treasuryAddress;
    }

    function setStakeRewardAddress(address _stakeRewardAddress) external onlyOwner{
        stakeRewardAddress = _stakeRewardAddress;
    }

    function getStakeRewardAddress() external view onlyOwner returns (address){
        return stakeRewardAddress;
    }

    function version() external pure returns (string memory) {
        return "1.0.0";
    }



}
