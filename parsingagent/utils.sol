
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Utils {

    string[] parsedRes;

constructor() {}


function stringToUint256(string memory str) public pure returns (uint256) {
        bytes memory tempBytes = bytes(str);
        uint256 result = 0;

        for (uint i = 0; i < tempBytes.length; i++) {
            uint8 b = uint8(tempBytes[i]);
            require(b >= 48 && b <= 57, "Invalid character in numeric string"); // Ensure it's 0-9
            result = result * 10 + (b - 48);
        }

        return result;
    }


    function stringToAddress(string memory str) public pure returns (address) {
        bytes memory tempBytes = bytes(str);
        require(tempBytes.length == 42, "Invalid address length");
        require(tempBytes[0] == '0' && (tempBytes[1] == 'x' || tempBytes[1] == 'X'), "Address must start with 0x");

        uint160 addr = 0;
        for (uint i = 2; i < 42; i++) {
            uint8 b = uint8(tempBytes[i]);
            if (b >= 48 && b <= 57) {
                addr = addr * 16 + (b - 48); // 0-9
            } else if (b >= 65 && b <= 70) {
                addr = addr * 16 + (b - 55); // A-F
            } else if (b >= 97 && b <= 102) {
                addr = addr * 16 + (b - 87); // a-f
            } else {
                revert("Invalid character in address");
            }
        }

        return address(addr);
    }

    function split(string memory str, string memory delimiter) public pure returns (string[] memory) {
        // Count the number of elements in the resulting array
        uint count = 1;
        for (uint i = 0; i < bytes(str).length; i++) {
            if (bytes(str)[i] == bytes(delimiter)[0]) {
                count++;
            }
        }

        string[] memory result = new string[](count);
        uint index = 0;
        bytes memory temp = bytes(str);
        bytes memory delim = bytes(delimiter);
        bytes memory buffer = new bytes(temp.length);

        uint j = 0;
        for (uint i = 0; i < temp.length; i++) {
            if (temp[i] == delim[0]) {
                result[index] = string(buffer);
                index++;
                buffer = new bytes(temp.length); // Reset buffer
                j = 0;
            } else {
                buffer[j++] = temp[i];
            }
        }

        // Add the last segment
        result[index] = string(buffer);

        return result;
    }



    function parseAndStoreString(string memory input) public returns (string[] memory){
            // Use the split function inherited from StringParser
            string[] memory parts = split(input, ",");
            
            // Store the parsed strings in the contract's state
            delete parsedRes;
            for (uint i = 0; i < parts.length; i++) {
                parsedRes.push(parts[i]);
            }


            return parsedRes;
        }



    function stringToBytes32(
        string memory source
    ) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }


    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

}