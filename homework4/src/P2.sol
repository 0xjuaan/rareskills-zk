// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";

contract Problem2_Matrix {

    struct ECPoint {
        uint256 x;
        uint256 y;
    }
    ECPoint public G;
    constructor() {
        G = ECPoint(1, 2);
    }

    uint256 public constant N = 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001;

    function matmul(
        uint256[] calldata matrix,
        uint256 n, // n x n for the matrix
        ECPoint[] calldata s, // n elements
        uint256[] calldata o // n elements
    ) public returns (bool verified) {

	    // revert if dimensions don't make sense or the matrices are empty
        require(matrix.length == n** 2, "wrong matrix size");
        require(s.length == n && o.length == n);

        ECPoint[] memory result = new ECPoint[](n);

        uint256 x;
        uint256 y;
        ECPoint memory temp;

        for (uint i = 0; i < n; i++) {
            for (uint j = 0; j < n; j++) {
                if (j == 0) (temp.x, temp.y) = _mulEC(s[j].x, s[j].y, matrix[i*n + j]);
                
                else {
                    (x, y) = _mulEC(s[j].x, s[j].y, matrix[i*n + j]);

                    (uint tempx, uint tempy) = _addEC(temp.x, temp.y, x, y);

                    temp = ECPoint(tempx, tempy);
                }
            }
            result[i] = temp;
        }

        // return true if Ms == o elementwise. You need to do n equality checks. If you're lazy, you can hardcode n to 3, but it is suggested that you do this with a for loop 

        for (uint k = 0; k < n; k++) {
            (uint x, uint y) = _mulEC(G.x, G.y, o[k]);

            if(x != result[k].x || y != result[k].y) return false;
        }
        return true;
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
