
/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import 'GamingObject.sol';

// This is class that describes you smart contract.
contract WarUnit is GamingObject {

    
    uint attackValue;


    function attack(GamingObject addressOfTarget) public {
        tvm.accept();
        // This function gets address of potential target object, and calls takeAHit in the target object.
        addressOfTarget.takeAHit(attackValue);
    }

    function setAttackValue(uint newAttackValue) virtual public {
        tvm.accept();
        attackValue = newAttackValue;
    }

    function setShieldValue(uint newShieldValue) virtual public {
        tvm.accept();
        shieldValue = newShieldValue;
    }

    function setHealthValue(uint newHealthValue) public {
        tvm.accept();
        healthValue = newHealthValue;
    }
    
    function destroyObject() internal override {
        tvm.accept();
        sendTransactionAndDestroy();
        // If Unit is dead, destroy Unit itself and call Bases function to delete Unit from struct.
    }

}