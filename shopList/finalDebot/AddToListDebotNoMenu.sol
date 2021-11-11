pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import '../ShoppingListInitDebot.sol';

contract AddToListDebotNoMenu is ShoppingListInitDebot {
    
    // This debot is dedicated to to storing adding function for finalDebot

    // Params needed for adding function
    string productName;
    uint32 productQuantity;

    // The first adding function that asks name of a product
    function askName(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(askQuantity), "Enter product name:", false);
    }

    // The second adding function that asks quantity of a product
    function askQuantity(string value) public {
        productName = value;
        Terminal.input(tvm.functionId(addProduct), "Enter product quantity:", false);
    }

    // The third adding function that adds product name and quntity alongside other basic info to the shopping list
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
