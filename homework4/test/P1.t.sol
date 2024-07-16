// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Problem1_Rationals} from "../src/P1.sol";

contract P1_Test is Test {
    Problem1_Rationals p1;

    struct ECPoint {
        uint256 x;
        uint256 y;
    }

    function setUp() public {
       p1 = new Problem1_Rationals();
    }

    function test_works() public {
        uint256 N = p1.N();
        (uint256 Gx, uint256 Gy) = p1.G();
        
        // Imagine i'm the prover

        // I take 421/454 + 643/531
        // This gives 515473/241074

        // Hence, 
        uint256 num = 515473;
        uint256 den = 241074;

        // Now calculating 421/454 in the field
        uint256 den1_inv = p1.modExp(454, N - 2, N);
        uint256 A = mulmod(421, den1_inv, N);

        // Now calculating 643/531 in the field
        uint256 den2_inv = p1.modExp(531, N-2, N);
        uint256 B = mulmod(643, den2_inv, N);

        // Now I don't want to give these away so I convert them to EC points by 
        // multiplying by G.

        // Due to difficulty of ECDLP, they can't figure out A or B from knowing A*G
        // To verify, they just have to check that A + B == (num/dem)G
        (uint256 numX, uint256 numY) = _mulEC(Gx, Gy, A);

        (uint256 denX, uint256 denY) = _mulEC(Gx, Gy, B);

        assertTrue(p1.rationalAdd(Problem1_Rationals.ECPoint(numX, numY), Problem1_Rationals.ECPoint(denX, denY), num, den));
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
}
