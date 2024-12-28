// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {console} from "forge-std/console.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

/**
 * Airdrop contract address : 0x8A791620dd6260079BF849Dc5567aDC3F2FdC318
 * Token contract address: 0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6
 * Data to sign : 0x9091b0ebdf95f8573c840c281530780f415daccd5193578c00e4fb986cb90a68
 * Signature : 0x99ceae8f610828c942a6b3900b7bf955f2331bbd53511942c98e44d06eda85d65b5a0396674676f2fd89b2bb34ee4b35d32539864407098760a90f9c32c4eefb1b
 * Anvil private key [0] : 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
 * Anvil private key [1] : 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
 */

contract ClaimAirdrop is Script {
    error ClaimAirdropScript__InvalidSignatureLength();

    address private constant CLAIMING_ADDRESS =
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private constant CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 private constant PROOF_ONE =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] private proof = [PROOF_ONE, PROOF_TWO];
    bytes private constant SIGNATURE =
        hex"99ceae8f610828c942a6b3900b7bf955f2331bbd53511942c98e44d06eda85d65b5a0396674676f2fd89b2bb34ee4b35d32539864407098760a90f9c32c4eefb1b";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );

        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = _splitSignature(SIGNATURE);

        MerkleAirdrop merkleAirdrop = MerkleAirdrop(mostRecentlyDeployed);
        merkleAirdrop.claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);

        vm.stopBroadcast();
    }

    function _splitSignature(
        bytes memory sig
    ) private pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65)
            revert ClaimAirdropScript__InvalidSignatureLength();
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 32))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
