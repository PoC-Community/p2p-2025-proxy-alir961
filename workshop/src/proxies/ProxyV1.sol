// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract ProxyV1 {
    uint256 public count;

    address public implem;

    constructor(address _implementation) {
        count = 0;
        implem = _implementation;
    }

    receive() external payable {}

    function implementation() public view returns (address) {
        return implem;
    }

    fallback() external payable {
        (bool success, bytes memory returnData) = implem.delegatecall(msg.data);

        if (success) {
            assembly {
                return(add(returnData, 0x20), mload(returnData))
            }
        } else {
            if (returnData.length > 0) {
                assembly {
                    revert(add(returnData, 0x20), mload(returnData))
                }
            }
            revert("ProxyV1: delegatecall failed");
        }
    }
}
