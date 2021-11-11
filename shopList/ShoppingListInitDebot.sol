pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "./imports/Debot.sol";
import "./imports/Terminal.sol";
import "./imports/Menu.sol";
import "./imports/AddressInput.sol";
import "./imports/ConfirmInput.sol";
import "./imports/Upgradable.sol";
import "./imports/Sdk.sol";
import 'ShoppingListInterfacesAndStructs.sol';

abstract contract ShoppingListInitDebot is Debot, Upgradable {
    
    // This debot is dedicated to running and deploying shopping list 

    bytes m_icon;
    // All params that InitDebot needs besides Structs
    TvmCell public m_shoppingListCode; // ShoppingList contract code
    TvmCell public m_shoppingListData; // ShoppingList contrcat data
    TvmCell public m_shoppingListStateInit; // ShoppingList contract stateInit
    address m_address;  // ShoppingList contract address
    ProductsSummary m_stat;  // Statistics of added and bought products
    uint32 m_productId;    // ProductId for buying function
    uint256 m_masterPubKey; // User pubkey
    address m_transactableAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial TODO contract balance

    function setShoppingListCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shoppingListCode = code;
        m_shoppingListData = data;
        m_shoppingListStateInit = tvm.buildStateInit(m_shoppingListCode, m_shoppingListData);
    }

    // On error, this function shows error code to caller.
    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }
    
    // If function is succed, call stat setting function.
    function onSuccess() public view {
        _getStat(tvm.functionId(setStat));
    }
    
    // Debot starts here.
    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);
    }

    // Returns information about Debot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "ShoppingList DeBot";
        version = "1.0.0";
        publisher = "BelenkoNick";
        key = "Shopping list manager";
        author = "BelenkoNick";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a ShoppingList DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
    
    // Gets all the imported interfaces
    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    // Saves caller pubkey and check if he has shopping list
    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;

            Terminal.print(0, "Checking if you already have a Shopping List list ...");
            TvmCell deployState = tvm.insertPubkey(m_shoppingListStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            
            // Prints shopping list address and then check if is alredy deployed and signed
            Terminal.print(0, format( "Info: your Shopping List contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);
        
        // This is called if the pubkey is wrong
        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // Contract is active and contract is already deployed
            _getStat(tvm.functionId(this.setStat));

        } else if (acc_type == -1)  { // Contract is inactive and Debot asks for payment
            Terminal.print(0, "You don't have a Shopping list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // Contract is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your Shopping List contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // Contract is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    // This function is called is caller needs to pay for deployment of shopping list
    function creditAccount(address value) public {
        m_transactableAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        // Calls payment interface 
        Transactable(m_transactableAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    // This function is a loop for payment
    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // Check errors if needed.
        sdkError;
        exitCode;
        creditAccount(m_transactableAddress);
    }

    // This function checks if payment is complete
    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfContractIsReady), m_address);
    }

    // This function checks if payment is complete and then based on ctatus deloys or returns to checking
    function checkIfContractIsReady(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    // This is deploy function
    function deploy() private view {
            TvmCell image = tvm.insertPubkey(m_shoppingListStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess), // Calls succed and stats setting function
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubKey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    // This function is a loop for deploy
    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }

    // This function is called after shopping list is proven to be working
    function setStat(ProductsSummary stats) virtual public {
        m_stat = stats;
        _menu();
    }

    // This function gets the statistics 
    function _getStat(uint32 answerId) private view {
        optional(uint256) none;
        shoppingListInterface(m_address).getStatistics{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    // This is an upgrade function overrided from Upgradable parent
    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    // This is blank menu overrided in child contracts
    function _menu() virtual public {
        
    }

}
