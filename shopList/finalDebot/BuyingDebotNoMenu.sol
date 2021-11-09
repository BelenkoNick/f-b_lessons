pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import '../ShoppingListInitDebot.sol';

contract BuyingDebotNoMenu is ShoppingListInitDebot {
    
    uint32 productPrice;

    function askNumber(uint32 index) public {
        index = index;
        if (m_stat.notBoughtCount > 0) {
            Terminal.input(tvm.functionId(askPrice), "Enter product number:", false);
        } else {
            Terminal.print(0, "Congrats, you have bought all your products!");
            _menu();
        }
    }

    function askPrice(string value) public {
        (uint256 num,) = stoi(value);
        m_productId = uint32(num);
        Terminal.input(tvm.functionId(buyProduct),"Enter price:", false);
    }

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
