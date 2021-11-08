pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct Product {
        uint32 id;
        string name;
        uint count;
        uint32 addedAt;
        bool isBought;
        uint32 priceOfPurchase;
    }

    struct ProductsSummary {
        uint32 boughtCount;
        uint32 notBoughtCount;
        uint32 totalSum;
    }

interface shoppingListInterface {
    function addProduct(string name, uint count) external;
    function buyProduct(uint32 id, bool isBought, uint32 price) external;
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
