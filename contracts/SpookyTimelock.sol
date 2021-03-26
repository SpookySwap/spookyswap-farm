// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "./SpookyToken.sol"; // should be spooktoken later

// The spookylock leverages using openzeppelin timelock for maximum safety. Its also spooky and haunted.
// To see openzepplin's audits goto: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/audit
contract SpookyTimelock {
    using SafeERC20 for IERC20;

    IERC20 public spook;
    IERC20 public spookLP;

    TokenTimelock[] public Locks;

    constructor (IERC20 _spook, IERC20 _spookLP) {

        spook = _spook;
        spookLP = _spookLP;
        uint currentTime = block.timestamp;

        createLock(_spook, msg.sender, currentTime + 60 days);
        createLock(_spook, msg.sender, currentTime + 120 days);
        createLock(_spook, msg.sender, currentTime + 180 days);
        createLock(_spook, msg.sender, currentTime + 240 days);
        createLock(_spookLP, msg.sender, currentTime + 365 days);
    }

    function createLock(IERC20 token, address sender, uint256 time) internal {
        TokenTimelock lock = new TokenTimelock(token, sender, time);
        Locks.push(lock);
    }

    // Attempts to release tokens. This is done safely with 
    // OpenZeppelin which checks the proper time has passed.
    // To see their code go to: 
    // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/TokenTimelock.sol
    function release(uint lock) external {
        Locks[lock].release();
    }

    function getLockAddress(uint lock) external view returns (address) {
        require(lock <= 4, "getLockAddress: lock doesnt exist");

        return address(Locks[lock]);
    }
    
    //Forward along tokens to their appropriate vesting place
    function forwardTokens() external {

        uint spooks = spook.balanceOf(address(this));
        uint spookLPs = spookLP.balanceOf(address(this));

        require(spooks > 0, "forwardTokens: no spooks!");
        require(spookLPs > 0, "forwardTokens: no spooky lps!");

        for (uint256 index = 0; index <= 3; index++) {
            spook.transfer(address(Locks[index]), spooks / 4);
        }

        // just incase theres any spooks left from rounding
        uint leftover = spook.balanceOf(address(this));

        if (leftover > 0) {
            spook.transfer(address(Locks[3]), leftover);
        }

        spookLP.safeTransfer(address(Locks[4]), spookLPs);
    }


}
