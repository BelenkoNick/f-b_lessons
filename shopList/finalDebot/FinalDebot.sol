pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import '../BaseMethodsDebot.sol';
import 'AddToListDebotNoMenu.sol';
import 'BuyingDebotNoMenu.sol';

contract FinalDebot is BaseMethodsDebot, AddToListDebotNoMenu, BuyingDebotNoMenu {

    // This Debot is a complete menu debot that imports all 4 options of adding, buying, removing and getting info

    // New overrided menu that contains 4 options
    function _menu() public override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                // Prints shopping list stats
                "You have {} products added to the list, {} added and already bought, and {} is a total sum of bought products)",
                    m_stat.boughtCount,
                    m_stat.notBoughtCount,
                    m_stat.totalSum
            ),
            sep,
            [
                // This function is imported from AddToListDebotNoMenu
                MenuItem("Add new product to the list","",tvm.functionId(askName)),
                // This function is imported from BuyingDebotNoMenu
                MenuItem("Buy product on the list","",tvm.functionId(askNumber)),
                // Those functions is imported from BaseMethodsDebot
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Remove product from the list","",tvm.functionId(askRemoveNumber))
            ]
        );
    }
}