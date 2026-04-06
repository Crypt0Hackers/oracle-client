// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title MaveriX Dollar (MXT)
/// @notice Collateral-backed synthetic dollar. 1 MXT = $1 by protocol design.
///         Only accounts with MINTER_ROLE (i.e. LendingPool) can mint tokens.
///         Burning is handled via ERC20Burnable — the LendingPool burns its own balance.
contract MXT is ERC20, ERC20Burnable, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("MaveriX Dollar", "MXT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
