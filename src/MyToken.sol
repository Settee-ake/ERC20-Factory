// SPDX-License-Identifier: AGPL-3.0-only

import {ERC20} from "./ERC20.sol";

pragma solidity 0.8.28;

contract MyToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 decimals,
        uint256 _totalSupply
    ) ERC20(_name, _symbol, decimals) {
        _mint(msg.sender, _totalSupply);
    }
}
