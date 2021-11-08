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
            callbackId: tvm.functionId(getShoppingList_),
            onErrorId: 0
        }();
    }

    function getShoppingList_( Product[] products ) public {
        uint32 i;
        if (products.length > 0 ) {
            Terminal.print(0, "Your tasks list:");
            for (i = 0; i < products.length; i++) {
                Product product = products[i];
                string bought;
                if (product.isBought) {
                    bought = '✓';
                } else {
                    bought = ' ';
                }
                Terminal.print(0, format("{} \"{}\" {} pieces {} for {} added at {}", product.id, product.name, bought, product.priceOfPurchase, product.count, product.addedAt));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function removeProduct(uint32 index) public {
        index = index;
        if (m_stat.boughtCount + m_stat.notBoughtCount > 0) {
            Terminal.input(tvm.functionId(removeProduct_), "Enter product number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no products to remove");
            _menu();
        }
    }

    function removeProduct_(string value) public view {
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
