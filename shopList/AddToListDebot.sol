pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';
import 'BaseMethodsDebot.sol';

contract AddToListDebot is ShoppingListInitDebot, BaseMethodsDebot {
    
    string productName;
    uint32 productQuantity;

    function _menu() public override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {} products added to the list, {} added and already bought, and {} is a total sum of bought products)",
                    m_stat.notBoughtCount,
                    m_stat.boughtCount,
                    m_stat.totalSum
            ),
            sep,
            [
                MenuItem("Add new product to the list","",tvm.functionId(askName)),
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Remove product from the list","",tvm.functionId(askRemoveNumber))
            ]
        );
    }

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
