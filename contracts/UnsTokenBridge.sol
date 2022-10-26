// contracts/UnsTokenBridge.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UnsTokenBridge is AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
    mapping(uint256 => bool) private _fulfillments;

    event WithdrawToken(address indexed dest, uint256 amount, address indexed token, uint256 fulfillmentId);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(GOVERNOR_ROLE, _msgSender());
    }

    /**
     * @notice Function to withdraw Token
     * Caller is assumed to be governance
     * @param token Address of token to be withdrawn
     * @param amount Amount of tokens
     * @param fulfillmentId id of fulfilment
     *
     * Requirements:
     *
     * - the caller must have the `GOVERNOR_ROLE`.
     */
    function withdrawToken(
        IERC20 token,
        uint256 amount,
        uint256 fulfillmentId
    ) external onlyRole(GOVERNOR_ROLE) {
        require(amount > 0, "!zero");
        require(!_fulfillments[fulfillmentId], "!fulfillmentId");
        _fulfillments[fulfillmentId] = true;
        token.safeTransfer(_msgSender(), amount);
        emit WithdrawToken(_msgSender(), amount, address(token), fulfillmentId);
    }

    /**
     * @dev fulfillmentId check
     */
    function fulfillments(uint256 fulfillmentId) public view virtual returns (bool) {
        return _fulfillments[fulfillmentId];
    }
}