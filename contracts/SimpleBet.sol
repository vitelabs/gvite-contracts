pragma soliditypp ^0.4.0;
contract ViteBet{
    address owner;
    tokenId token = "tti_5649544520544f4b454e6e40";

    event win(address indexed addr, uint256 rollTarget, uint256 betAmount, uint64 rollNum, uint256 winAmount);
    event lose(address indexed addr, uint256 rollTarget, uint256 betAmount, uint64 rollNum);
    event suspendBet(address indexed addr, uint256 rollTarget, uint256 betAmount, uint64 rollNum);

    constructor() public {
        owner = msg.sender;
    }

    onMessage Transfer() payable {
    }

    onMessage DrawMoney() {
        require(owner == msg.sender);
        uint256 amount = address(this).balance(token);
        require(amount > 0);
        msg.sender.transfer(token, amount);
    }

    onMessage BetAndRoll(uint256 rollTargets) payable {
        uint256 betAmount = msg.value;
        address betAddr = msg.sender;
        require(msg.tokenid == token);
        require(betAmount >= 1 vite && betAmount <= 100 vite);
        require(rollTargets > 0 && rollTargets < 100000);

        bytes32 randomhash = blockhash(block.number);
        uint64 rollNum = uint64(uint256(randomhash) % 6 + 1);
        bool winBet = false;
        uint64 count = 0;
        uint256 tempRollTargets = rollTargets;
        while(tempRollTargets % 10 > 0) {
            count++;
            uint64 rollTarget = uint64(tempRollTargets % 10);
            require(rollTarget > 0 && rollTarget <= 6);
            if(rollTarget == rollNum) {
                winBet = true;
            }
            tempRollTargets = tempRollTargets / 10;
        }
        uint256 winAmount = calcWinAmount(betAmount, count);

        if(winBet == false) {
            betAddr.transfer(token, 0);
            emit lose(betAddr, rollTargets, betAmount, rollNum);
        } else if(winBet == true && winAmount > address(this).balance(token)) {
            betAddr.transfer(token, betAmount);
            emit suspendBet(betAddr, rollTargets, betAmount, rollNum);
        } else {
            betAddr.transfer(token, winAmount);
            emit win(betAddr, rollTargets, betAmount, rollNum, winAmount);
        }

    }

    function calcWinAmount(uint256 betAmount, uint256 length) public pure returns(uint256) {
        uint256 bonus = betAmount * 6 / length;
        return (bonus - betAmount) * 5 / 100;
    }

}