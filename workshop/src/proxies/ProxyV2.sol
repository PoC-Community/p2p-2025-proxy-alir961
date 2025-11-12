// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract ProxyV2 {
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    constructor(address _implementation) {
        setImplementation(_implementation);
    }

    function _setImplementation(address newImplementation) internal {
        require(newImplementation != address(0), "ProxyV2: invalid implementation");

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    function setImplementation(address newImplementation) public virtual {
        _setImplementation(newImplementation);
    }

    function getImplementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    fallback() external payable {
        address impl = getImplementation();
        require(impl != address(0), "ProxyV2: implementation not set");

        (bool success, bytes memory returnData) = impl.delegatecall(msg.data);

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
            revert("ProxyV2: delegatecall failed");
        }
    }

    receive() external payable {}
}
