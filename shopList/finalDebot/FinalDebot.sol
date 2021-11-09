pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import '../BaseMethodsDebot.sol';
import 'AddToListDebotNoMenu.sol';
import 'BuyingDebotNoMenu.sol';

contract FinalDebot is BaseMethodsDebot, AddToListDebotNoMenu, BuyingDebotNoMenu {

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
                MenuItem("Add new product to the list","",tvm.functionId(askName)),
                MenuItem("Buy product on the list","",tvm.functionId(askNumber)),
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Remove product from the list","",tvm.functionId(askRemoveNumber))
            ]
        );
    }
}