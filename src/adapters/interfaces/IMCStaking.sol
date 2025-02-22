// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

/// @title Staking Interface
/// @notice Interface for staking operations and rebase functionality
/// @dev Implements core staking mechanics and rebase calculations for protocol
interface IMCStaking {
    /// @notice Thrown when attempting operation with insufficient token balance
    error InsufficientBalance();
    /// @notice Thrown when caller lacks required permissions
    error AccessRestricted();
    /// @notice Thrown when provided node key is not registered in the system
    error InvalidNodeKey();
    /// @notice Thrown when amount is zero or invalid for operation
    error InvalidAmount();
    /// @notice Thrown when provided address is zero
    error InvalidAddress();
    /// @notice Thrown when attempting to claim with no available rewards
    error NothingToClaim();
    /// @notice Thrown when no stake record exists for specified node
    error NoStakeFoundForProvidedNodeKey();
    /// @notice Thrown when input arrays lengths mismatch
    error InvalidLength();

    /// @notice Triggers a rebase event to adjust staking rewards
    function rebase() external returns (uint256);

    /// @notice Stakes tokens on behalf of an address
    /// @param node The validator address, which `staker` makes deposit to
    /// @param amount The amount of tokens to stake
    /// @param staker Staker address for deposit attribution
    function stake(address node, uint256 amount, address staker) external;

    /// @notice Allows a user to claim their accumulated rewards
    /// @return reward The amount of rewards claimed
    function claim() external returns (uint256 reward);

    /// @notice Claims accumulated rewards from a validator
    /// Any user claims the rewards using this function.
    /// When a node claims it claims their staking and node records.
    /// When a staker claims it claims their staking records only.
    /// @dev Handles validator fee distribution
    /// @param claimer Staker address
    /// @return reward Amount of rewards claimed
    function claim(address claimer) external returns (uint256 reward);

    /// @notice Withdraws staked tokens from a validator
    /// @dev Checks timelock in registry before allowing withdrawal
    /// @param node Validator address
    /// @param amount Amount to withdraw
    function withdraw(address node, uint256 amount) external;

    /// @notice Registers a node with a fee
    /// @param node Address of node to register
    function registerNode(address node) external;

    /// @notice Registers a node with a fee
    /// @param nodes Array of nodes addresses
    function registerNodes(address[] calldata nodes) external;

    /// @notice Shows if address is a node
    /// @param _node account address in question
    /// @return _ true if account is a node, otherwise false
    function isNode(address _node) external view returns (bool);

    /// @notice Returns total amount of tokens staked on all validators for a given `staker`
    /// @param staker address of the staker
    /// @return _ amount of total staked tokens
    function stakerTotalDeposit(address staker) external view returns (uint256);
}