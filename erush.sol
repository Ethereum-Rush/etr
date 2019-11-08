pragma solidity >=0.5.12 <0.6.0;

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract EthereumRush {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public fundsWallet;
    uint256 public maximumTarget;
    uint256 public lastBlock;
    uint256 public rewardTimes;
    uint256 public genesisReward;
    uint256 public premined;


    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed from, uint256 value);


    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        initialSupply = 21000000  * 10 ** uint256(decimals);
        tokenName = "Ethereum Rush";
        tokenSymbol = "ETR";
        lastBlock = 1;
        genesisReward = 50;
        maximumTarget = 100;
        fundsWallet = msg.sender;
        premined = 1000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = premined;
        balanceOf[address(this)] = initialSupply;
        totalSupply =  initialSupply + premined;
        name = tokenName;
        symbol = tokenSymbol;
    }


    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }


    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }


    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }


    function getdifficulity() public view returns (uint) {
            return uint(block.difficulty);
    }

    function checkRewardStatus() public view returns (bool) {
      uint256 crew = uint(block.difficulty) % 7200;
      if(crew == 1){
        return true;
      } else {
        return false;
      }
    }


    struct sdetails {
      uint256 stocktime;
      uint256 stockamount;
      uint256 blocknumber;
    }


    mapping (uint256 => sdetails[]) stockdetails;


    function numberofminer(uint256 Nblock) view public returns (uint256) {
        return stockdetails[Nblock].length;
    }


    function nAddrHash() view public returns (uint256) {
        return uint256(msg.sender) % 10000;
    }






    function becameaminer(uint256 mineamount) payable public returns (uint) {

      uint256 newMineAmount = mineamount * 10 ** uint256(decimals);
      //require(balanceOf[msg.sender] >= newMineAmount );
      //_transfer(msg.sender, address(this), newMineAmount);
      // 404 -> 504 -> 604

      if(balanceOf[msg.sender] < maximumTarget / 100) {
        //its can not be small than one percent of maximumTarget
        return 504;
      } else if(balanceOf[msg.sender] > maximumTarget / 100) {
        require(stockdetails[lastBlock][nAddrHash()].stocktime != 0);
        maximumTarget = balanceOf[msg.sender];
        stockdetails[lastBlock][nAddrHash()].stocktime = now;
        stockdetails[lastBlock][nAddrHash()].stockamount = balanceOf[msg.sender];
        stockdetails[lastBlock][nAddrHash()].blocknumber = lastBlock;
      } else {
        //thats means new amount and maximumTarget is equals but its not possible.
        return 604;
        }


   }




   function getmyreward() public view returns (uint256)  {
       require(checkRewardStatus() == true);
       //miner can get his money but we need to know some detaiils at the here
       //1. we need to know block number.
       //2. we need to know totaluser numner in this periot.
       //3. we need to know maximumTarget value
       //4. we need to know users amout end we can calculate reward amount.





   }





   //end of the contract
 }
