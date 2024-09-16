// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Sort {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function sort(int8[] memory disorderArr) public payable returns (int8[] memory) {
        for (int i = int(disorderArr.length) - 1; i >= 0; i--) {
            for (uint j = 0; j < uint(i); j++) {
                if (disorderArr[j] > disorderArr[j + 1]) {
                    int8 t = disorderArr[j];
                    disorderArr[j] = disorderArr[j + 1];
                    disorderArr[j + 1] = t; 
                }
            }
        }
        return disorderArr;
    }
}
