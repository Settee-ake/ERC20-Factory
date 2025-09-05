// SPDX-License-Identifier: AGPL-3.0-only

import {MyToken} from "./MyToken.sol";

pragma solidity 0.8.28;

contract Factory {
    function deployToken(string memory _name, string memory _symbol, uint8 decimals, uint256 _totalSupply)
        external
        returns (address)
    {
        address to = msg.sender;
        address token = address(
            new MyToken{salt: keccak256(abi.encode(to, block.timestamp, _name, _symbol, decimals))}(
                _name, _symbol, decimals, _totalSupply * decimals, to
            )
        );
        return token;
    }
}
