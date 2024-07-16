// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";

contract Problem1_Rationals {

    struct ECPoint {
        uint256 x;
        uint256 y;
    }
    ECPoint public G;
    constructor() {
        G = ECPoint(1, 2);
    }

    uint256 public constant N = 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001;
    
    function rationalAdd(ECPoint calldata A, ECPoint calldata B, uint256 num, uint256 den) public returns (bool verified) {
        // return true if the prover knows two numbers that add up to num/den
         
        // note that we will work with modulus = N (curve order of BN256)
        
        (uint256 sumX, uint256 sumY) = _addEC(A.x, A.y, B.x, B.y);

        uint256 den_inv = modExp(den, N - 2, N);

        uint256 fraction = mulmod(num, den_inv, N);

        (uint256 mulX, uint256 mulY) = _mulEC(G.x, G.y, fraction);

        return (sumX == mulX && sumY == mulY);
    }

    function _addEC(uint256 x1, uint256 y1, uint256 x2, uint256 y2) internal view returns (uint256, uint256) {
        (bool ok, bytes memory result) = address(6).staticcall(abi.encode(x1, y1, x2, y2));
        require(ok, "call failed");
        return abi.decode(result, (uint256, uint256));
    }

    function _mulEC(uint256 x, uint256 y, uint256 s) internal view returns (uint256, uint256) {
        (bool ok, bytes memory result) = address(7).staticcall(abi.encode(x, y, s));
        require(ok, "call failed");
        return abi.decode(result, (uint256, uint256));
    }

    function modExp(uint256 base, uint256 exponent, uint256 modulus) public returns (uint256 result) {
        bytes memory input = abi.encodePacked(
            uint256(32),    // Length of the base (32 bytes)
            uint256(32),    // Length of the exponent (32 bytes)
            uint256(32),    // Length of the modulus (32 bytes)
            base,           // The base
            exponent,       // The exponent
            modulus         // The modulus
        );
        
        bytes memory output = new bytes(32); // Output will be 32 bytes (256 bits)
        
        // Call the precompiled contract at address 0x05
        assembly {
            if iszero(staticcall(gas(), 0x05, add(input, 0x20), 0xc0, add(output, 0x20), 0x20)) {
                revert(0, 0)
            }
        }
        
        // Convert the output bytes to uint256
        result = abi.decode(output, (uint256));
    }
}
