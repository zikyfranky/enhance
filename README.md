===================
# CONTRACTS
===================

Token: https://bscscan.com/address/0xc444a5511e4e7F582608Ee79f0c6d621e049e7DF

DividendTracker: https://bscscan.com/address/0x2d10A64CC8351924f3dE3B3B1F2eFfE7314CC44d

Pair: https://bscscan.com/address/0xd0F7bb685C469d5287d7CE8Fa84590f55c7d580f

Router: https://bscscan.com/address/0xE804f3C3E6DdA8159055428848fE6f2a91c2b9AF

IterableMapping: https://bscscan.com/address/0x0355160615DD47C22b8f3a4eD8177Ce39a90cE83

RewardToken: https://bscscan.com/address/0x42981d0bfbAf196529376EE702F2a9Eb9092fcB5

===================
# METHODS
===================

1. `approve(spender, amount)` => Approves `spender` to spend amount of token from caller balance

2. `blacklist(account)` => to blacklist `account`

3. `blacklistMultipleAccounts(accounts)` => to blacklist multiple addresses [addr1, addr2]

4. `claim()` => claims caller's reward

5. `decreaseAllowance(spender, subtractedValue)` => subtract `subtractedValue` from spender allowance

6. `excludeFromDividends(account)` => exclude account from receiving rewards

7. `excludeFromFees(account)` => exclude account from paying taxes

8. `excludeMultipleAccountsFromFees(accounts)` => exclude all passed accounts from paying taxes

9. `getDividendStuckETH()` => Gets BNB stuck/sent in dividendContract

10. `getDividendStuckTokens(_token)` => Gets stuck/sent token of `_token` in dividendContract excluding reward token

11. `getStuckETH()` => Gets stuck/sent bnb in token contract

12. `getStuckTokens(_token)` => Gets stuck/sent token of `_token` in token contract excluding reward token

13. `includeInDividends(account)` => include `account` to receive rewards

14. `includeInFees(account)` => include `account` to paying taxes

15. `includeMultipleAccountsFromFees(accounts)` => include all passed accounts in paying taxes

16. `increaseAllowance(spender, addedValue)` => exact opposite of function 5

17. `limitAddress(account)` => Makes `account` to be capped per transaction

18. `processDividendTracker(gas)` => trigger auto distribution manually where `gas` is the gas caller is willing to pay for distribution

19. `renounceOwnership()` => transfers ownership to address(0)

20. `setAutomatedMarketMakerPair(pair, value)` => turn on/off an address as market maker where `value` is either `true/1` or `false/0`

21. `setLiquidityFee(value)` => set's liquidity tax to `value`

22. `setMissionControlFee(value)` => set's missionControl tax to `value`

23. `setRewardsFee(value)` => set's rewards tax to `value`
    - **liquidityFee + missionControlFee + rewardsFee can never exceed 100%**

24. `setRewardsToken(newReward)` => set's reward token to `newReward` (token must be listed on current router)

25. `setTransferFee(value)` => set's basic transfer tax to `value`

25. `transfer(recipient, amount)` => transfers `amount` to `receipient`

27. `transferFrom(sender, receipient, amount)` => transfers `amount` from  `sender`'s balance

28. `transferOwnership(newOwner)` => transfers ownership to `newOwner`

29. `unlimitAddress(account)` => exact opposite of `function #17`

30. `updateClaimWait(claimWait)` => update wait time between distrubutions for users, must be between `1 hour` and `a day(24 hours)` in `seconds`

31. `updateDividendTracker(newAddress)` => change dividendTracker to a newly deployed tracker(newAddress).

32. `updateFeeReceiver(newReceiver)` => changes tax receiver to `newReceiver`

33. `updateGasForProcessing(newValue)` => change gas used for processing(in the case gas increases in the future)

34. `updateLimitPercent(value)` => Increase/reduce user's limit per transaction

35. `updateMinimumTokenBalanceForDividends(_value)` => update minimum token to hold to receive rewards

36. `updateMissionToken(_newMissionToken)` => change missioncontrol token to `address(0)` to receive BNB and to a token to receive said token.. token MUST be listed on current router

37. `updateSwapAmount(value)` => change amount of token ENH contract must have as balance before disbursing all taxes to (dividend, mission control and liquidity)

38. `updateSwapRouter(newAddress)` => change router to a different router or version of router 

39. `whitelist(account)` => exact opposite of `function #2`

40. `whitelistMultipleAccounts(accounts)` => exact opposite of `function #3`