// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";

contract Pairing {

    struct G1Point {
        uint256 x;
        uint256 y;
    }

    struct G2Point {
        uint256 x1;
        uint256 y1;
        uint256 x2;
        uint256 y2;
    }

    uint256 constant G1_ORDER = 0x30644E72E131A029B85045B68181585D2833E84879B9709143E1F593F0000001;
    uint256 constant FIELD_MODULUS = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
    G1Point G1;
    G1Point alpha1;
    G1Point X1;
    G1Point C1;

    G1Point A1;
    G2Point B2;

    G2Point beta2;
    G2Point gamma2;
    G2Point delta2;

    constructor() {
        G1 = G1Point(1, 2);

        alpha1.x = 20453939078259811958859768391452073654460321168773748684493785442363495374770;
        alpha1.y = 9582859829925552874957318860636821932456214701004608986274201852321144884827;

        beta2.x1 = 20954117799226682825035885491234530437475518021362091509513177301640194298072;
        beta2.x2 = 21508930868448350162258892668132814424284302804699005394342512102884055673846;
        beta2.y1 = 4540444681147253467785307942530223364530218361853237193970751657229138047649;
        beta2.y2 = 11631839690097995216017572651900167465857396346217730511548857041925508482915;

        gamma2.x1 = 15512671280233143720612069991584289591749188907863576513414377951116606878472;
        gamma2.x2 = 13376798835316611669264291046140500151806347092962367781523498857425536295743;
        gamma2.y1 = 18551411094430470096460536606940536822990217226529861227533666875800903099477;
        gamma2.y2 = 1711576522631428957817575436337311654689480489843856945284031697403898093784;

        delta2.x1 = 18936818173480011669507163011118288089468827259971823710084038754632518263340;
        delta2.x2 = 18825831177813899069786213865729385895767511805925522466244528695074736584695;
        delta2.y1 = 18556147586753789634670778212244811446448229326945855846642767021074501673839;
        delta2.y2 = 13775476761357503446238925910346030822904460488609979964814810757616608848118;

    }

    function check(G1Point memory A1, G2Point memory B2, G1Point memory C1, uint256 x1, uint256 x2, uint256 x3) public returns(bool) {

        (X1.x, X1.y) = _calculateX1(x1, x2, x3);

        console.log("A1.x", A1.x);
        console.log("A1.y", A1.y);
        console.log("neg(A1).y", _negate(A1).y);

        G1Point[4] memory g1Points = [_negate(A1), alpha1, X1, C1];
        G2Point[4] memory g2Points = [B2, beta2, gamma2, delta2];

        uint256[] memory inputData = new uint256[](6 * 4);

        for (uint256 i = 0; i < 4; i++) {
            uint256 j = 6*i;

            inputData[0 + j] = g1Points[i].x;
            inputData[1 + j] = g1Points[i].y;

            inputData[2 + j] = g2Points[i].y1;
            inputData[3 + j] = g2Points[i].x1;
            inputData[4 + j] = g2Points[i].y2;
            inputData[5 + j] = g2Points[i].x2;
        }

        
        (bool success, ) = address(8).staticcall(abi.encodePacked(inputData));
        return success;

        //bool success = pairing(A1, B2, alpha1, beta2, X1, gamma2, C1, delta2);

        /*
        (bool success, ) = address(8).staticcall(abi.encode(
            inputData[0], inputData[1], inputData[2], inputData[3], inputData[4], inputData[5],
            inputData[6], inputData[7], inputData[8], inputData[9], inputData[10], inputData[11],
            inputData[12], inputData[13], inputData[14], inputData[15], inputData[16], inputData[17],
            inputData[18], inputData[19], inputData[20], inputData[21], inputData[22], inputData[23] 
        ));
        */

    }    

    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[4] memory p1 = [a1, b1, c1, d1];
        G2Point[4] memory p2 = [a2, b2, c2, d2];


        uint256 inputSize = 24;
        uint256[] memory input = new uint256[](inputSize);


        for (uint256 i = 0; i < 4; i++) {
        uint256 j = i * 6;
        input[j + 0] = p1[i].x;
        input[j + 1] = p1[i].y;

        input[j + 2] = p2[i].y1;
        input[j + 3] = p2[i].x1;
        input[j + 4] = p2[i].y2;
        input[j + 5] = p2[i].x2;
        }


        uint256[1] memory out;
        bool success;


        // solium-disable-next-line security/no-inline-assembly
        assembly {
        success := staticcall(gas(), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        }
        return success;



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

    function _calculateX1(uint256 x1, uint256 x2, uint256 x3) public view returns(uint256 x, uint256 y) {
        G1Point memory p1;
        (p1.x, p1.y) = _mulEC(G1.x, G1.y, x1);

        G1Point memory p2;
        (p2.x, p2.y) = _mulEC(G1.x, G1.y, x2);

        G1Point memory p3;
        (p3.x, p3.y) = _mulEC(G1.x, G1.y, x3);

        G1Point memory intermediate;
        (intermediate.x, intermediate.y)  = _addEC(p1.x, p1.y, p2.x, p2.y);

        (x, y) = _addEC(intermediate.x, intermediate.y, p3.x, p3.y);
    }

    function _negate(G1Point memory p) internal pure returns(G1Point memory) {
        if (p.x == 0 && p.y == 0) return G1Point(0, 0);
        else return G1Point(p.x, FIELD_MODULUS - p.y);
    }
}
