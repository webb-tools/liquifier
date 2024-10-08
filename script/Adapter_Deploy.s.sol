// SPDX-License-Identifier: UNLICENSED

// solhint-disable no-console

pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";

import { Registry } from "core/registry/Registry.sol";

import { LivepeerAdapter, LPT, VERSION as LPT_VERSION } from "core/adapters/LivepeerAdapter.sol";
import { GraphAdapter, GRT, VERSION as GRT_VERSION } from "core/adapters/GraphAdapter.sol";
import { PolygonAdapter, POL, VERSION as POL_VERSION } from "core/adapters/PolygonAdapter.sol";
import { ChainlinkAdapter, LINK, VERSION as LINK_VERSION } from "core/adapters/ChainlinkAdapter.sol";

contract Adapter_Deploy is Script {
    uint256 VERSION;
    // Contracts are deployed deterministically.
    // e.g. `foo = new Foo{salt: salt}(constructorArgs)`
    // The presence of the salt argument tells forge to use https://github.com/Arachnid/deterministic-deployment-proxy

    // address private constant MATIC = 0x0;

    function run() public {
        // Start broadcasting with private key from `.env` file
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Registry registry = Registry(vm.envAddress("REGISTRY"));
        address asset = vm.envAddress("ASSET");

        address adapter;

        // On local testing node, the token addresses will be different than mainnet
        // So do not compare token addresses
        // check which adapter to deploy
        if (asset == address(LPT)) {
            adapter = address(new LivepeerAdapter{ salt: bytes32(LPT_VERSION) }());
        } else if (asset == address(GRT)) {
            adapter = address(new GraphAdapter{ salt: bytes32(GRT_VERSION) }());
        } else if (asset == address(POL)) {
            adapter = address(new PolygonAdapter{ salt: bytes32(POL_VERSION) }());
        } else if (asset == address(LINK)) {
            adapter = address(new ChainlinkAdapter{ salt: bytes32(LINK_VERSION) }());
        } else {
            revert("Adapter not supported");
        }

        console2.log("Adapter Address: ", adapter);

        // register adapter
        registry.registerAdapter(asset, adapter);
    }
}
