pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingListInitDebot.sol';

contract BuyingDebot is ShoppingListInitDebot {
    
    function _menu() private{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (todo/done/total) tasks",
                    m_stat.boughtCount,
                    m_stat.notBoughtCount,
                    m_stat.totalSum
            ),
            sep,
            [
                MenuItem("Buy some products","",tvm.functionId(buyProduct))
            ]
        );
    }

    function buyProduct(uint32 index) public {
        index = index;
        if (m_stat.boughtCount + m_stat.notBoughtCount > 0) {
            Terminal.input(tvm.functionId(buyProduct_), "Enter product number:", false);
        } else {
            Terminal.print(0, "Congrats, you have bought all your products!");
            _menu();
        }
    }

    function buyProduct_(uint32 price) public view {
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
            }(m_productId,true, price);
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }
}
