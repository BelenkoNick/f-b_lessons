pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract Wallet {
    /*
     Exception codes:
      100 - message sender is not a wallet owner.
      101 - invalid transfer value.
     */

    constructor() public {
        
        require(tvm.pubkey() != 0, 101);
        
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }


    
    modifier checkOwnerAndAccept {
        
        require(msg.pubkey() == tvm.pubkey(), 100);

		tvm.accept();
		_;
	}

    
    function sendTransaction(address dest, uint128 value, bool bounce, uint16 flag) public pure checkOwnerAndAccept {
        dest.transfer(value, bounce, flag);
    }

    function sendTransactionWithCommisssion(address dest, uint128 value) public pure checkOwnerAndAccept {
        dest.transfer(value, true, 1);
    }

    function sendTransactionWithoutCommisssion(address dest, uint128 value) public pure checkOwnerAndAccept {
        dest.transfer(value, true, 0);
    }

    function sendTransactionAndDestroyWallet(address dest, uint128 value) public pure checkOwnerAndAccept {
        dest.transfer(value, true, 160);
    }

}