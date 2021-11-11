pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';
import 'BaseMethodsDebot.sol';

contract BuyingDebot is ShoppingListInitDebot, BaseMethodsDebot {
    
    // This debot is dedicated to buying products on the list

    // Params needed for buying function
    uint32 productPrice;

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
                MenuItem("Buy product on the list","",tvm.functionId(askNumber)),
                // Those functions is imported from BaseMethodsDebot
                MenuItem("Show shopping list","",tvm.functionId(getShoppingList)),
                MenuItem("Remove product from the list","",tvm.functionId(askRemoveNumber))
            ]
        );
    }

    // The first buying function that asks index of a product
    function askNumber(uint32 index) public {
        index = index;
        if (m_stat.notBoughtCount > 0) {
            Terminal.input(tvm.functionId(askPrice), "Enter product number:", false);
        } else {
            Terminal.print(0, "Congrats, you have bought all your products!");
            _menu();
        }
    }

    // The second buying function that asks price of a product
    function askPrice(string value) public {
        (uint256 num,) = stoi(value);
        m_productId = uint32(num);
        Terminal.input(tvm.functionId(buyProduct),"Enter price:", false);
    }

    // The third buying function that chages product status to "Bought" and sets price as caller inputs
    function buyProduct(string value) public {
        (uint256 price,) = stoi(value);
        productPrice = uint32(price);
        optional(uint256) pubkey = 0;
        shoppingListInterface(m_address).buyProduct{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_productId, productPrice);
    }
}
