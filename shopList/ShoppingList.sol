pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import 'ShoppingListInterfacesAndStructs.sol';

contract ShoppingList {
    

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 purchasesCount;
    mapping(uint32 => Product) m_products;

    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function addProduct(string name, uint count) public onlyOwner {
        tvm.accept();
        purchasesCount++;
        m_products[purchasesCount] = Product(purchasesCount, name, count, now, false, 0);
    }

    function buyProduct(uint32 id, uint32 price) public onlyOwner {
        optional(Product) purchase = m_products.fetch(id);
        require(purchase.hasValue(), 102);
        tvm.accept();
        Product thisPurchase = purchase.get();
        thisPurchase.isBought = true;
        thisPurchase.priceOfPurchase = price;
        m_products[id] = thisPurchase;
    }

    function removeProduct(uint32 id) public onlyOwner {
        require(m_products.exists(id), 102);
        tvm.accept();
        delete m_products[id];
    }

    //
    // Get methods
    //

    function getShoppingList() public view returns (Product[] products) {
        string name;
        uint count;
        uint32 addedAt;
        bool isBought;
        uint32 priceOfPurchase;

        for((uint32 id, Product product) : m_products) {
            name = product.name;
            count = product.count;
            addedAt = product.addedAt;
            isBought = product.isBought;
            priceOfPurchase = product.priceOfPurchase;
            products.push(Product(id, name, count, addedAt, isBought, priceOfPurchase));
       }
    }

    function getStatistics() public view returns (ProductsSummary stats) {
        uint32 PurchasedCount;
        uint32 NotPurchasedCount;
        uint32 totalSum;

        for((, Product product) : m_products) {
            if  (product.isBought) {
                PurchasedCount ++;
                totalSum += product.priceOfPurchase;
            } else {
                NotPurchasedCount ++;
            }
        }
        stats = ProductsSummary ( PurchasedCount, NotPurchasedCount, totalSum );
    }
}
