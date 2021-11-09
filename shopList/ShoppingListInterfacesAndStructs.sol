pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct Product {
        uint32 id;
        string name;
        uint32 quantity;
        uint64 addedAt;
        bool isBought;
        uint32 priceOfPurchase;
    }

    struct ProductsSummary {
        uint32 boughtCount;
        uint32 notBoughtCount;
        uint64 totalSum;
    }

interface shoppingListInterface {
    function addProduct(string name, uint32 quantity) external;
    function buyProduct(uint32 id, uint32 price) external;
    function removeProduct(uint32 id) external;
    function getShoppingList() external returns (Product[] products);
    function getStatistics() external returns (ProductsSummary);
}

interface Transactable {
    function sendTransaction (address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) external;
}

abstract contract HasConstructorWithPubKey {
    constructor(uint256 pubkey) public {}
}
