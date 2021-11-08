pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';

contract AddToListDebot is ShoppingListInitDebot {
    
    function _menu() private {
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
                MenuItem("Add new product to the list","",tvm.functionId(addProduct))
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

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }
}
