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
    uint256 public nRewarMod;
    uint256 public nWtime;

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
        nRewarMod = 7200;
        nWtime = 7889231; //thats means three months
        genesisReward = 50  * 10 ** uint256(decimals);
        maximumTarget = 100  * 10 ** uint256(decimals);
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



    function uintToString(uint256 v) internal pure returns(string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function append(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"-",b));
    }




    function getdifficulity() public view returns (uint) {
            return uint(block.difficulty);
    }

    function checkRewardStatus() public view returns (bool) {
      uint256 crew = uint(block.difficulty) % nRewarMod;
      if(crew == 1){
        return true;
      } else {
        return false;
      }
    }


    struct sdetails {
      uint256 _stocktime;
      uint256 _stockamount;
    }


    address[] totalminers;

    mapping (address => sdetails) nStockDetails;
    struct rewarddetails {
        uint256 _artyr;
        bool _didGetReward;
    }
    mapping (string => rewarddetails) nRewardDetails;

    struct nBlockDetails {
        uint256 _bTime;
        uint256 _tInvest;
    }
    mapping (uint256 => nBlockDetails) bBlockIteration;


  struct activeMiners {
      address bUser;
  }

  mapping(uint256 => activeMiners[]) aMiners;


    function numberofminer() view public returns (uint256) {
        return totalminers.length;
    }


    function nAddrHash() view public returns (uint256) {
        return uint256(msg.sender) % 10000000000;
    }

     function getmaximumAverage() public view returns(uint){
         return  maximumTarget / totalminers.length;
    }


    function nMixAddrandBlock()  public view returns(string memory) {
         return append(uintToString(nAddrHash()),uintToString(lastBlock));
    }

    function becameaminer(uint256 mineamount) payable public returns (uint256) {
      uint256 realMineAmount = mineamount * 10 ** uint256(decimals);
      require(balanceOf[msg.sender] < getmaximumAverage() / 100); //Minimum maximum targes one percents neccessary.
      require(balanceOf[msg.sender] > 1 * 10 ** uint256(decimals)); //minimum 1 coin require
      require(nStockDetails[msg.sender]._stocktime != 0);
      maximumTarget +=  realMineAmount;
      nStockDetails[msg.sender]._stocktime = now;
      nStockDetails[msg.sender]._stockamount = mineamount;
      totalminers.push(msg.sender);
      _transfer(msg.sender, address(this), mineamount);
      return 200;
   }



   function signfordailyreward() public returns (uint256)  {
       require(checkRewardStatus() == true);
       require(nRewardDetails[nMixAddrandBlock()]._artyr == 0);  //Register this block for reward.
       if(bBlockIteration[lastBlock]._bTime < now + 666){
           lastBlock += 1;
           bBlockIteration[lastBlock]._bTime = now;
       }

       bBlockIteration[lastBlock]._tInvest += nStockDetails[msg.sender]._stockamount;
       nRewardDetails[nMixAddrandBlock()]._artyr = now;
       nRewardDetails[nMixAddrandBlock()]._didGetReward = false;
       aMiners[lastBlock].push(activeMiners(msg.sender));


       return 200;

   }

   function getactiveminersnumber() view public returns(uint256) {
        return aMiners[lastBlock].length; //that function for information.
   }


   function getDailyReward() public returns(uint256) {
      uint256 usersReward = (nStockDetails[msg.sender]._stockamount * 100) / bBlockIteration[lastBlock]._tInvest;
       _transfer(address(this), msg.sender, usersReward);
       return 200;
   }



   function getyourcoinsbackafterthreemonths() public returns(uint256) {
       require(nRewardDetails[nMixAddrandBlock()]._artyr > now + nWtime);
       _transfer(address(this),msg.sender,nStockDetails[msg.sender]._stockamount);
       return nStockDetails[msg.sender]._stockamount;
   }

   //end of the contract
 }
