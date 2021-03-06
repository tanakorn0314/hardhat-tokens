//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MintableToken.sol";
import "./time/TimeCounter.sol";

contract MinableToken is MintableToken {
    uint256 public faucetRate;
    uint256 public maxElapsed;

    TimeCounter public counter;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 _decimals,
        address committee_,
        address adminRouter_,
        address kyc_,
        uint256 acceptedKycLevel_,
        uint256 faucetRate_,
        uint256 maxElapsed_,
        address counter_
    ) MintableToken(name_, symbol_, _decimals, committee_, adminRouter_, kyc_, acceptedKycLevel_) {
        require(
            faucetRate_ > 0,
            "MinableToken: faucet rate must be greater than 0"
        );
        require(
            maxElapsed_ > 0,
            "MinableToken: maxElapsed rate must be greater than 0"
        );

        faucetRate = faucetRate_;
        maxElapsed = maxElapsed_;
        counter = TimeCounter(counter_);
    }

    function getMiningReward() public view returns (uint256) {
        return getMiningRewardInternal(msg.sender);
    }

    function getMiningRewardInternal(address user) internal view returns (uint256) {
        uint256 actualElapsed = counter.getElapsedTimeOf(user);
        uint256 elapsed = actualElapsed > maxElapsed
            ? maxElapsed
            : actualElapsed;
        return (faucetRate * elapsed) / maxElapsed;
    }

    function mine() public {
        _mint(msg.sender, getMiningReward());
        counter.stampLastAction(msg.sender);
    }

    function mineBKNext(address bkNextAddr) public onlySuperAdmin {
        _mint(bkNextAddr, getMiningRewardInternal(bkNextAddr));
        counter.stampLastAction(bkNextAddr);
    }
}
