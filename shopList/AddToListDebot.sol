pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';
import 'BaseMethodsDebot.sol';

contract AddToListDebot is ShoppingListInitDebot, BaseMethodsDebot {
    
    // This debot is dedicated to adding products to the list

    // Params needed for adding function
    string productName;
    uint32 productQuantity;

    // New overrided menu that contains 3 options
    function _menu() public override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                // Prints shopping list stats
                "You have {} products added to the list, {} added and already bought, and {} is a total sum of bought products)",
                    m_stat.notBoughtCount,
                    m_stat.boughtCount,
                    m_stat.totalSum
            ),
            sep,
            [
                MenuItem("Add new product to the list","",tvm.functionId(askName)),
                // Those functions is imported from BaseMethodsDebot
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Remove product from the list","",tvm.functionId(askRemoveNumber))
            ]
        );
    }

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
