// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol';
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

// The spookylock leverages using openzeppelin timelock for maximum safety. Its also spooky and haunted.
// To see openzepplin's audits goto: https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/audit
contract SpookyTimelock {
    using SafeERC20 for IERC20;

    IERC20 public boo;
    IERC20 public booLP;

    TokenTimelock[] public Locks;

    constructor (IERC20 _boo, IERC20 _booLP) {

        boo = _boo;
        booLP = _booLP;
        uint currentTime = block.timestamp;

        createLock(_boo, msg.sender, currentTime + 60 days);
        createLock(_boo, msg.sender, currentTime + 120 days);
        createLock(_boo, msg.sender, currentTime + 180 days);
        createLock(_boo, msg.sender, currentTime + 240 days);
        createLock(_booLP, msg.sender, currentTime + 365 days);
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

        uint boos = boo.balanceOf(address(this));
        uint booLPs = booLP.balanceOf(address(this));

        require(boos > 0, "forwardTokens: no boos!");
        require(booLPs > 0, "forwardTokens: no spooky lps!");

        for (uint256 index = 0; index <= 3; index++) {
            boo.transfer(address(Locks[index]), boos / 4);
        }

        // just incase theres any boos left from rounding
        uint leftover = boo.balanceOf(address(this));

        if (leftover > 0) {
            boo.transfer(address(Locks[3]), leftover);
        }

        booLP.safeTransfer(address(Locks[4]), booLPs);
    }


}
