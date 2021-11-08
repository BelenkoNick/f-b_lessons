pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';
import 'BuyingDebot.sol';
import 'BaseMethodsDebot.sol';

contract AddToListDebot is ShoppingListInitDebot, BuyingDebot, BaseMethodsDebot {
    
    function _menu() public override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {} products added to the list, {} added and already bought, and {} is a total sum of bought products)",
                    m_stat.boughtCount,
                    m_stat.notBoughtCount,
                    m_stat.totalSum
            ),
            sep,
            [
                MenuItem("Add new product to the list","",tvm.functionId(addProduct)),
                MenuItem("Buy some products","",tvm.functionId(buyProduct)),
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Remove product from the list","",tvm.functionId(removeProduct))
            ]
        );
    }

    function addProduct(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(addProduct_), "One line please:", false);
    }

    function addProduct_(string name, uint count) public view {
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
            }(name, count);
    }
}
