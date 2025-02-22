// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

import { Adapter } from "liquifier/src/adapters/Adapter.sol";
import { IStaking } from "./interfaces/IStaking.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { IERC165 } from "liquifier/src/interfaces/IERC165.sol";

contract MCAdapter is Adapter {
    using SafeTransferLib for ERC20;

    IStaking public immutable MCStaking;
    ERC20 public immutable MCToken;

    struct Storage {
        uint256 lastRebaseTimestamp;
    }
    
    uint256 private constant STORAGE = uint256(keccak256("xyz.liquifier.mc.adapter.storage.location")) - 1;

    constructor(address _staking, address _token) {
        MCStaking = IStaking(_staking);
        MCToken = ERC20(_token);
    }

    function _loadStorage() internal pure returns (Storage storage $) {
        uint256 slot = STORAGE;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            $.slot := slot
        }
    }

    function previewDeposit(address /*_validator*/, uint256 _assets) external pure returns (uint256) {
        return _assets;
    }

    function unlockMaturity(uint256 /*_unlockID*/) external pure returns (uint256) {
        // assets could be withdrawn at any time since the staking begins
        return 0;
    }

    function unlockTime() external pure returns (uint256) {
        // there is no concept of cooldown
        return 0;
    }

    function currentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function withdraw(address /*_validator*/, uint256 /*_unlockID*/) external pure returns (uint256 amount) {
        // MC staking has no concept of unbonding nor cooldown, deposits can be withdrawn right away
        return 0;
    }

    function unstake(address _validator, uint256 _amount) external returns (uint256) {
        MCStaking.withdraw(_validator, _amount);
        return _amount;
    }

    function previewWithdraw(uint256/*unlockID*/) external view returns (uint256) {
        // MC staking does not have cooldowns nor unbonding, everything is withdrawn in unstake
        // return total amount of staked tokens
        return MCStaking.stakerTotalDeposit(address(this));
    }

    function stake(address _validator, uint256 _amount) external returns (uint256) {
        MCToken.safeApprove(address(MCStaking), _amount);
        MCStaking.stake(_validator, _amount, address(this));
        return _amount;
    }

    function rebase(address /*validator*/, uint256/*currentStake*/) external returns (uint256) {
        // MC staking has a strict rebase schedule based on time passed, so no arguments needed
    }

    function isValidator(address _validator) external view returns (bool) {
        return MCStaking.isNode(_validator);
    }

    function supportsInterface(bytes4 _interfaceId) external pure override returns (bool) {
        return _interfaceId == type(Adapter).interfaceId || _interfaceId == type(IERC165).interfaceId;
    }
}