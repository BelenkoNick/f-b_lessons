pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';

contract BaseMethodsDebot is ShoppingListInitDebot{
    
    function getShoppingList(uint32 index) public view {
        index = index;
        optional(uint256) none;
        shoppingListInterface(m_address).getShoppingList{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showShoppingList),
            onErrorId: 0
        }();
    }

    function showShoppingList( Product[] products ) public {
        uint32 i;
        if (products.length > 0 ) {
            Terminal.print(0, "Your products list:");
            for (i = 0; i < products.length; i++) {
                Product product = products[i];
                string bought;
                if (product.isBought) {
                    bought = 'Yes';
                } else {
                    bought = 'No';
                }
                Terminal.print(0, format("{}. Product: {}, {} pieces. Bought: {}, for the price of {}. Product Added at {}.", product.id, product.name, product.quantity, bought, product.priceOfPurchase, product.addedAt));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function askRemoveNumber(uint32 index) public {
        index = index;
        if (m_stat.boughtCount + m_stat.notBoughtCount > 0) {
            Terminal.input(tvm.functionId(removeProduct), "Enter product number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no products to remove");
            _menu();
        }
    }

    function removeProduct(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        shoppingListInterface(m_address).removeProduct{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
}
