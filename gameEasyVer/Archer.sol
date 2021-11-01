
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'WarUnit.sol';

// This is class that describes you smart contract.
contract Archer is WarUnit {

    constructor() public {
        tvm.accept();
        healthValue = 5;
        shieldValue = 0;
        attackValue = 7;
    }

    
    function setAttackValue(uint newAttackValue) public override {
        tvm.accept();
        attackValue = newAttackValue;
    }

    function setShieldValue(uint newShieldValue) public override {
        tvm.accept();
        shieldValue = newShieldValue;
    }

}
