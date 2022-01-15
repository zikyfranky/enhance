// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IRouter.sol";
import "./DividendTracker.sol";
import "./GetStuck.sol";

/**
    * ENCHANCE proposes an innovative feature in its contract.
    *
    * DIVIDEND YIELD PAID IN SAFEMOON! With the auto-claim feature,
    * simply hold ENCHANCE and you'll receive SAFEMOON automatically in your wallet.
    * 
    * Hold ENCHANCE and get rewarded in SAFEMOON on every transaction!
*/

contract TRY is ERC20, Ownable, GetStuck{

    IRouter02 public swapRouter;
    address public swapPair;

    bool private swapping;

    DividendTracker public dividendTracker;

    address private DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable private feeReceiver = payable(0x7054281a2808C56c372B894578529F97Bb366AF5);
    
    address private REWARD = 0x42981d0bfbAf196529376EE702F2a9Eb9092fcB5; // SAFEMOON
    address private missionToken; // address(0) for BNB earnings
    
    uint256 public swapTokensAtAmount = 10000000 * (10**18);
    uint256 public userLimit = 20; // 20% of user's balance

    uint256 public rewardsFee = 11;
    uint256 public liquidityFee = 1;
    uint256 public missionControlFee = 2;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 private gasForProcessing = 400000;
    
    // Blacklist address
    mapping(address => bool) public _isBlacklisted;

    // Exclude from user cap per transaction
    mapping(address => bool) public _isNotLimited;

     // exlcude from fees and max transaction amount
    mapping (address => bool) public _isExcludedFromFees;

    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) private automatedMarketMakerPairs;
    
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);

    event UpdateSwapRouter(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account);
    event ExcludeMultipleAccountsFromFees(address[] accounts);
    event IncludeInFees(address indexed account);
    event IncludeMultipleAccountsInFees(address[] accounts);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event BlacklistAccount(address indexed account);
    event BlacklistMultipleAccounts(address[] accounts);
    event WhitelistAccount(address indexed account);
    event WhitelistMultipleAccounts(address[] accounts);

    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );

    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() ERC20("TRY", "TRY") {
        // address  _newOwner = 0x7054281a2808C56c372B894578529F97Bb366AF5;
        address  _newOwner = msg.sender;
        
    	dividendTracker = new DividendTracker(REWARD);
    	
        IRouter02 _swapRouter = IRouter02(0xE804f3C3E6DdA8159055428848fE6f2a91c2b9AF); //SAFEMOON_SWAP MAINNET
        // IRouter02 _swapRouter = IRouter02(0x303BD61Fb70E563BbE833fA698D3ADa22Fd2DACa);//SAFEMOON_SWAP TESTNET

         // Create a pair for this new token
        address _swapPair = IFactory(_swapRouter.factory())
            .createPair(address(this), _swapRouter.WETH());

        swapRouter = _swapRouter;
        swapPair = _swapPair;

        _setAutomatedMarketMakerPair(swapPair, true);
        init(_newOwner);

        // unlimit addresses
        _isNotLimited[_newOwner] = true;
        _isNotLimited[address(this)] = true;
        _isNotLimited[address(swapRouter)] = true;
        _isNotLimited[swapPair] = true;
        
        // exclude from paying fees
        _isExcludedFromFees[_newOwner] = true;
        _isExcludedFromFees[address(this)] = true;

        emit ExcludeFromFees(_newOwner);
        emit ExcludeFromFees(address(this));
        
        // Transfer ownaship to owner
        // transferOwnership(_newOwner);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        // SEND TOTAL_SUPPLY TO OWNER  
        _mint(owner(), 1000000000000000 * (1e18));
    }

    receive() external payable {
  	}

    function init(address _owner) private {

        // exclude from receiving dividends
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(_owner);
         dividendTracker.excludeFromDividends(DEAD); 
        dividendTracker.excludeFromDividends(address(0));
        dividendTracker.excludeFromDividends(address(swapRouter));
        dividendTracker.excludeFromDividends(swapPair);

    }

    function updateFeeReceiver(address payable newReceiver) external onlyOwner {
        feeReceiver = newReceiver;
    }

    function updateSwapAmount(uint256 value) external onlyOwner {
        swapTokensAtAmount = value;
    }

    function updateLimitPercent(uint256 value) external onlyOwner {
        require(value <= 100, "exceed 100%");
        userLimit = value;
    }

    function updateMinimumTokenBalanceForDividends(uint256 _value) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(_value);
    }

    function minimumTokenBalanceForDividends() external view returns(uint256) {
        return dividendTracker.minimumTokenBalanceForDividends();
    }
    
    function blacklist(address account) external onlyOwner {
        if(!_isBlacklisted[account]){
            _isBlacklisted[account] = true;
            emit BlacklistAccount(account);
        }
    }

    function blacklistMultipleAccounts(address[] memory accounts) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            if(!_isBlacklisted[accounts[i]]){
                _isBlacklisted[accounts[i]] = true;
            }
        }
        emit BlacklistMultipleAccounts(accounts);
    }
    
    function whitelist(address account) external onlyOwner {
        if(_isBlacklisted[account]){
            _isBlacklisted[account] = false;
            emit WhitelistAccount(account);
        }
    }

    function whitelistMultipleAccounts(address[] memory accounts) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            if(_isBlacklisted[accounts[i]]){
                _isBlacklisted[accounts[i]] = false;
            }
        }
        emit WhitelistMultipleAccounts(accounts);
    }

    function limitAddress(address account) external onlyOwner{
        if(_isNotLimited[account]){
            _isNotLimited[account] = false;
        }
    }

    function unlimitAddress(address account) external onlyOwner{
        if(!_isNotLimited[account]){
            _isNotLimited[account] = true;
        }
    }

    function updateDividendTracker(address newAddress) external onlyOwner {
        require(newAddress != address(dividendTracker), "ENCHANCE: The dividend tracker already has that address");

        DividendTracker newDividendTracker = DividendTracker(payable(newAddress));

        require(newDividendTracker.owner() == address(this), "ENCHANCE: The new dividend tracker must be owned by the token contract");

        dividendTracker = newDividendTracker;
        
        init(owner());

        emit UpdateDividendTracker(newAddress, address(dividendTracker));
    }

    function updateSwapRouter(address newAddress) external onlyOwner {
        require(newAddress != address(swapRouter), "ENCHANCE: The router already has that address");

        swapRouter = IRouter02(newAddress);
        address _swapPair = IFactory(swapRouter.factory()).getPair(address(this), swapRouter.WETH());
        
        if(swapPair == address(0)){
            _swapPair = IFactory(swapRouter.factory()).createPair(address(this), swapRouter.WETH());
        }

        swapPair = _swapPair;
        _setAutomatedMarketMakerPair(swapPair, true);
        // exclude from dividends
        init(owner());

        emit UpdateSwapRouter(newAddress, address(swapRouter));
    }

    function excludeFromFees(address account) external onlyOwner {
        if(!_isExcludedFromFees[account]){
            _isExcludedFromFees[account] = true;
            emit ExcludeFromFees(account);
        }
    }

    function excludeMultipleAccountsFromFees(address[] memory accounts) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            if(!_isExcludedFromFees[accounts[i]]){
                _isExcludedFromFees[accounts[i]] = true;
            }
        }

        emit ExcludeMultipleAccountsFromFees(accounts);
    }

    function includeInFees(address account) external onlyOwner {
        if(_isExcludedFromFees[account]){
            _isExcludedFromFees[account] = false;
            emit IncludeInFees(account);
        }
    }

    function includeMultipleAccountsInFees(address[] memory accounts) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            if(_isExcludedFromFees[accounts[i]]){
                _isExcludedFromFees[accounts[i]] = false;
            }
        }

        emit IncludeMultipleAccountsInFees(accounts);
    }

    function setRewardsToken(address newReward) external onlyOwner{
        REWARD = newReward;
        dividendTracker.changeRewardToken(newReward);
    }

    function setRewardsFee(uint256 value) external onlyOwner{
        require(value <= 100, "exceeds 100%");
        rewardsFee = value;
    }

    function setLiquidityFee(uint256 value) external onlyOwner{
        require(value <= 100, "exceeds 100%");
        liquidityFee = value;
    }

    function setMissionControlFee(uint256 value) external onlyOwner{
        require(value <= 100, "exceeds 100%");
        missionControlFee = value;
    }

    
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        require(pair != swapPair, "ENCHANCE: The swap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        if(automatedMarketMakerPairs[pair] == value) return;
        
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue >= 200000 && newValue <= 500000, "ENCHANCE: gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "ENCHANCE: Cannot update gasForProcessing to same value");
        gasForProcessing = newValue;

        emit GasForProcessingUpdated(newValue, gasForProcessing);
    }

    function updateMissionToken(address _newMissionToken) external onlyOwner {
        missionToken = _newMissionToken;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) external view returns(uint256) {
    	return dividendTracker.withdrawableDividendOf(account);
  	}

	function dividendTokenBalanceOf(address account) external view returns (uint256) {
		return dividendTracker.balanceOf(account);
	}

	function excludeFromDividends(address account) external onlyOwner{
	    dividendTracker.excludeFromDividends(account);
	}

	function includeInDividends(address account) external onlyOwner{
	    dividendTracker.includeInDividends(account);
	}

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

	function processDividendTracker(uint256 gas) external {
		(uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function isLimitedPercent(uint256 _value, address _user) private view returns(bool){
        if(!_isNotLimited[_user]){
            uint256 _percent = (balanceOf(_user) * userLimit) / 100;
            if (_value <= _percent ) {
                return true;
            } else {
                return false;
            }
        }
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isBlacklisted[from] && !_isBlacklisted[to], 'Blacklisted address');

        require(isLimitedPercent(amount, from), "amount greater than cap per transaction");

		if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != owner() &&
            to != owner()
        ) {
            swapping = true;
            
            uint256 totalFees = rewardsFee + liquidityFee + missionControlFee;
            if(totalFees > 0){
                uint256 missionControl = (contractTokenBalance * missionControlFee) / totalFees;
                swapAndSendToMissionControl(missionControl);

                uint256 swapTokens = (contractTokenBalance * liquidityFee) / totalFees;
                swapAndLiquify(swapTokens);

                uint256 dividendTokens = (contractTokenBalance * rewardsFee) / totalFees;
                swapAndSendDividends(dividendTokens);
            }


            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
			uint256 feePercent = rewardsFee + liquidityFee + missionControlFee;

            if(feePercent > 0){
                uint256 fees = (amount * feePercent) / 100;
        	    amount = amount - fees;
                super._transfer(from, address(this), fees);
            }
        }

        super._transfer(from, to, amount);

        try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if(!swapping) {
	    	uint256 gas = gasForProcessing;

	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
	    	}
	    	catch {
	    	}
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the swapPair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(swapRouter), tokenAmount);

        // add the liquidity
        swapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function swapTokensForMissionToken(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        path[2] = missionToken;

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForReward(uint256 tokenAmount) private {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = swapRouter.WETH();
        path[2] = REWARD;

        _approve(address(this), address(swapRouter), tokenAmount);

        // make the swap
        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapAndSendToMissionControl(uint256 tokens) private  {
        if(tokens > 0) {
            if(missionToken == address(0)) {
                uint256 initialBalance = address(this).balance;

                // swap tokens for ETH
                swapTokensForEth(tokens);

                // how much ETH did we just swap into?
                uint256 newBalance = address(this).balance - initialBalance;
                feeReceiver.call{value: newBalance}("");
            }else{
                uint256 initialMissionTokenBalance = IERC20(missionToken).balanceOf(address(this));

                swapTokensForMissionToken(tokens);
                uint256 newMBalance = IERC20(missionToken).balanceOf(address(this)) - initialMissionTokenBalance;
                IERC20(missionToken).transfer(feeReceiver, newMBalance);
            }
        }
    }

    function swapAndLiquify(uint256 tokens) private {
        if(tokens > 0) {
            // split the contract balance into halves
            uint256 half = tokens / 2;
            uint256 otherHalf = tokens - half;

            // capture the contract's current ETH balance.
            // this is so that we can capture exactly the amount of ETH that the
            // swap creates, and not make the liquidity event include any ETH that
            // has been manually sent to the contract
            uint256 initialBalance = address(this).balance;

            // swap tokens for ETH
            swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

            // how much ETH did we just swap into?
            uint256 newBalance = address(this).balance - initialBalance;

            // add liquidity to PancakeSwap
            addLiquidity(otherHalf, newBalance);

            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
    }

    function swapAndSendDividends(uint256 tokens) private{
        if(tokens > 0) {
            swapTokensForReward(tokens);
            uint256 dividends = IERC20(REWARD).balanceOf(address(this));

            bool success = IERC20(REWARD).transfer(address(dividendTracker), dividends);

            if (success) {
                dividendTracker.distributeDividends(dividends);
                emit SendDividends(tokens, dividends);
            }
        }
    }

    function getStuckTokens(IERC20 _token) external onlyOwner {
        require(address(_token) != address(this), "Cannot get stuck tokens for this contract");
        _getStuckTokens(_token, owner());
    }

    function getStuckETH() external onlyOwner {
        _getStuckETH(owner());
    }

    function getDividendStuckTokens(IERC20 _token) external onlyOwner {
        dividendTracker.getStuckTokens(_token, owner());
    }

    function getDividendStuckETH() external onlyOwner {
        dividendTracker.getStuckETH(owner());
    }

}