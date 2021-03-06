pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import 'ShoppingListInterfacesAndStructs.sol';

contract ShoppingList {

    // This is the main code for all shopping list functions
    
// Modifier requered to check the owner Pubkey
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 purchasesCount;
    mapping(uint32 => Product) m_products;

    uint256 m_ownerPubkey;
// Constructor recieves caller pubkey and sets it as Owner's
    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }
// Adds products to the list
    function addProduct(string name, uint32 quantity) public onlyOwner {
        tvm.accept();
        purchasesCount++;
        m_products[purchasesCount] = Product(purchasesCount, name, quantity, now, false, 0);
    }
// Sets product status as "bought" on the list
    function buyProduct(uint32 id, uint32 price) public onlyOwner {
        require(m_products.exists(id), 102);
        tvm.accept();
        m_products[id].isBought = true;
        m_products[id].priceOfPurchase = price;
    }
// Removes prosuct from the list
    function removeProduct(uint32 id) public onlyOwner {
        require(m_products.exists(id), 102);
        tvm.accept();
        delete m_products[id];
    }

    // Get stats functions

    // This function returns all the product info
    function getShoppingList() public view returns (Product[] products) {
        string name;
        uint32 quantity;
        uint64 addedAt;
        bool isBought;
        uint32 priceOfPurchase;

        for((uint32 id, Product product) : m_products) {
            name = product.name;
            quantity = product.quantity;
            addedAt = product.addedAt;
            isBought = product.isBought;
            priceOfPurchase = product.priceOfPurchase;
            products.push(Product(id, name, quantity, addedAt, isBought, priceOfPurchase));
       }
    }
    // This function returns stats about shopping list
    function getStatistics() public view returns (ProductsSummary stats) {
        uint32 PurchasedCount;
        uint32 NotPurchasedCount;
        uint64 totalSum;

        for((, Product product) : m_products) {
            if  (product.isBought) {
                PurchasedCount++;
                totalSum += product.priceOfPurchase;
            } else {
                NotPurchasedCount++;
            }
        }
        stats = ProductsSummary ( PurchasedCount, NotPurchasedCount, totalSum );
    }
}
