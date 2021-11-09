pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import '../ShoppingListInitDebot.sol';

contract AddToListDebotNoMenu is ShoppingListInitDebot {
    
    string productName;
    uint32 productQuantity;

    function askName(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(askQuantity), "Enter product name:", false);
    }

    function askQuantity(string value) public {
        productName = value;
        Terminal.input(tvm.functionId(addProduct), "Enter product quantity:", false);
    }

    function addProduct(string value) public {
        (uint256 count,) = stoi(value);
        productQuantity = uint32(count);
        optional(uint256) pubkey = 0;
        shoppingListInterface(m_address).addProduct{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(productName, productQuantity);
    }
}
