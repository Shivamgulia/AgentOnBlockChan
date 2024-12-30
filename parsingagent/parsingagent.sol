// // SPDX-License-Identifier: MIT
// // pragma solidity 0.8.19;
// pragma solidity ^0.8.7;


// import {Chainlink, ChainlinkClient} from "@chainlink/contracts@1.2.0/src/v0.8/ChainlinkClient.sol";
// import {ConfirmedOwner} from "@chainlink/contracts@1.2.0/src/v0.8/shared/access/ConfirmedOwner.sol";
// import {LinkTokenInterface} from "@chainlink/contracts@1.2.0/src/v0.8/shared/interfaces/LinkTokenInterface.sol";



// /**
//  * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
//  * DO NOT USE THIS CODE IN PRODUCTION.
//  */

// contract LLMCaller is ChainlinkClient, ConfirmedOwner {

//     using Chainlink for Chainlink.Request;


//     uint256 private constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18
//     string public responce;
//     string [] public parsedRes;


//     constructor() ConfirmedOwner(msg.sender) {
//         _setChainlinkToken(0x9A57E62D53e17E8D6b1E288679d942F0AAfC9542);
//         responce = "Hello";
//     }


//     event RequestLLMFullfilled(
//         bytes32 indexed requestId,
//         string value
//     );

//     function split(string memory str, string memory delimiter) public pure returns (string[] memory) {
//         // Count the number of elements in the resulting array
//         uint count = 1;
//         for (uint i = 0; i < bytes(str).length; i++) {
//             if (bytes(str)[i] == bytes(delimiter)[0]) {
//                 count++;
//             }
//         }

//         string[] memory result = new string[](count);
//         uint index = 0;
//         bytes memory temp = bytes(str);
//         bytes memory delim = bytes(delimiter);
//         bytes memory buffer = new bytes(temp.length);

//         uint j = 0;
//         for (uint i = 0; i < temp.length; i++) {
//             if (temp[i] == delim[0]) {
//                 result[index] = string(buffer);
//                 index++;
//                 buffer = new bytes(temp.length); // Reset buffer
//                 j = 0;
//             } else {
//                 buffer[j++] = temp[i];
//             }
//         }

//         // Add the last segment
//         result[index] = string(buffer);

//         return result;
//     }



//     function parseAndStoreString(string memory input) public returns (string[] memory){
//             // Use the split function inherited from StringParser
//             string[] memory parts = split(input, ",");
            
//             // Store the parsed strings in the contract's state
//             delete parsedRes;
//             for (uint i = 0; i < parts.length; i++) {
//                 parsedRes.push(parts[i]);
//             }


//             return parsedRes;
//         }



//     function stringToBytes32(
//         string memory source
//     ) private pure returns (bytes32 result) {
//         bytes memory tempEmptyStringTest = bytes(source);
//         if (tempEmptyStringTest.length == 0) {
//             return 0x0;
//         }

//         assembly {
//             // solhint-disable-line no-inline-assembly
//             result := mload(add(source, 32))
//         }
//     }


//     function compareStrings(string memory a, string memory b) internal pure returns (bool) {
//         return keccak256(bytes(a)) == keccak256(bytes(b));
//     }



//     function fulfillLLM(
//         bytes32 _requestId,
//         string  memory _text
//     ) public recordChainlinkFulfillment(_requestId) {
//         emit RequestLLMFullfilled(_requestId, _text);
//         responce = _text;

//         string [] memory resultarray = parseAndStoreString(responce);
//         // parsedRes = resultarray;

//         callFunctionBasedonResponce(resultarray[0]);

//     }

//     function requestLLM(
//         address _oracle,
//         string memory _jobId,
//         string memory _prompt
//     ) public onlyOwner {
//         Chainlink.Request memory req = _buildChainlinkRequest(
//             stringToBytes32(_jobId),
//             address(this),
//             this.fulfillLLM.selector
//         );

//         string memory formatedPrompt = "You are an AI agent capable of solving tasks by using a predefined set of tools. Your response must always be in the given format to ensure compatibility."
// "The format for your responses should be as follows: functionname,functionargument1,functionargument2"
// "Key guidelines: 1. Function Execution: When solving a task, choose the appropriate tool from the list provided to perform the task. 2. Response Format: Your response must include: - The name of the tool as \"functionName\". - All the required inputs as \"arguments\" . 3. Handling Missing Information: - If you cannot complete the task due to missing information, use the \"returnResult\" tool to explain why the task cannot be performed and request the missing details. - Example: \"I need the 'accountID' to complete this task.\""
//     "4. Tool Selection: The tools you can use to solve the problems are listed below:"
//      "A - functionname - checkBalance - it is used to check wallet balance of a blockchain wallet or details of a blockchin wallet. it needs the public address of the wallet as argument for function checkBalance. eg responce : - checkbalance,YOUR_WALLET_ADDRESS"
//      "B - functionname - sum - it is used to sum two numbers. it will take two numbers as arguments. eg responce : - sum,first_number,second-number"
//      "C - functionname - diff - it is used to get difference between two numbers. it will take two numbers as arguments. eg responce : - diff,first_number,second-number"
//      "D - functionname - multpily - it is used to get prduct of two numbers. it will take two numbers as arguments. eg responce : - multiply,first_number,second-number"
//      "E - functionname - divide - it is used to get division of two numbers. it will take two numbers as arguments. eg responce : - divide,first_number,second-number"
//      "F - functionname - returnsResult - it is used to return your reason if all the other tools can not be used, or return answers for the questiom. eg : - responce : returnsResult,YOUR_RESPONCE"
//     "6. Task Execution:"
//        "- Only perform a task if explicitly asked to do so."
//        "- If no specific task is mentioned or the provided information is insufficient, use the \"returnResult\" tool to provide feedback or ask clarifying questions."
//     "7. Output Constraints: Always ensure that the output is:"
//        "- Easily parsable."
//        "- Properly formatted as array."
//     "Remember to keep your responses structured, concise, and in the required JSON format for seamless integration."
//     "the example resonce would be --  checkbalance,YOUR_WALLET_ADDESS "
//     "The task i want you to do is \n";

//     string memory finalPrompt = string.concat(formatedPrompt, _prompt);


//         req._add("path", "candidates,0,content,parts,0,text");
//         req._add("prompt", finalPrompt);


//         _sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
//     }



//     function getChainlinkToken() public view returns (address) {
//         return _chainlinkTokenAddress();
//     }

//     function withdrawLink() public onlyOwner {
//         LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
//         require(
//             link.transfer(msg.sender, link.balanceOf(address(this))),
//             "Unable to transfer"
//         );
//     }

//     function cancelRequest(
//         bytes32 _requestId,
//         uint256 _payment,
//         bytes4 _callbackFunctionId,
//         uint256 _expiration
//     ) public onlyOwner {
//         _cancelChainlinkRequest(
//             _requestId,
//             _payment,
//             _callbackFunctionId,
//             _expiration
//         );
//     }

//     function callFunctionBasedonResponce(string memory functionName) public {

//         if (compareStrings(functionName, "sum\n")) {
//             sum(1873, 628);
//         }
//         else if (compareStrings(functionName, "diff\n")) {
//             diff(10000,2222);
//         }
//         else if (compareStrings(functionName, "multiply\n")) {
//             multiply(2, 15);
//         }
//         else if (compareStrings(functionName, "divide\n")) {
//             divide(1000, 20);
//         }
//         else if (compareStrings(functionName, "checkbalance\n")) {
//             checkBalance(0x5416A1B78E89d891018570CDbdD4954c31e52D6e);
//         }
   



//     }


//     struct Operation {
//             string functionName;
//             uint256[] inputs;
//             uint256 result;
//             uint256 timestamp;
//             address caller;
//         }

//     // operations part
//      // Array to store all operations
//     Operation[] public operationHistory;
    
//     // Events
//     event Calculation(string operation, uint256[] inputs, uint256 result);
//     event BalanceChecked(address account, uint256 balance);
    
//     // Function to check balance of any address
//     function checkBalance(address _address) public returns (uint256) {
//         uint256 balance = _address.balance;
        
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = uint256(uint160(_address));
        
//         Operation memory newOperation = Operation({
//             functionName: "checkBalance",
//             inputs: inputs,
//             result: balance,
//             timestamp: block.timestamp,
//             caller: msg.sender
//         });
        
//         operationHistory.push(newOperation);
//         emit BalanceChecked(_address, balance);
//         return balance;
//     }
    
//     // Function to add two numbers
//     function sum(uint256 a, uint256 b) public returns (uint256) {
//         uint256 result = a + b;
        
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = a;
//         inputs[1] = b;
        
//         Operation memory newOperation = Operation({
//             functionName: "sum",
//             inputs: inputs,
//             result: result,
//             timestamp: block.timestamp,
//             caller: msg.sender
//         });
        
//         operationHistory.push(newOperation);
//         emit Calculation("Addition", inputs, result);
//         return result;
//     }
    
//     // Function to subtract two numbers
//     function diff(uint256 a, uint256 b) public returns (uint256) {
//         require(a >= b, "First number must be greater than or equal to second number");
//         uint256 result = a - b;
        
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = a;
//         inputs[1] = b;
        
//         Operation memory newOperation = Operation({
//             functionName: "diff",
//             inputs: inputs,
//             result: result,
//             timestamp: block.timestamp,
//             caller: msg.sender
//         });
        
//         operationHistory.push(newOperation);
//         emit Calculation("Subtraction", inputs, result);
//         return result;
//     }
    
//     // Function to multiply two numbers
//     function multiply(uint256 a, uint256 b) public returns (uint256) {
//         uint256 result = a * b;
        
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = a;
//         inputs[1] = b;
        
//         Operation memory newOperation = Operation({
//             functionName: "multiply",
//             inputs: inputs,
//             result: result,
//             timestamp: block.timestamp,
//             caller: msg.sender
//         });
        
//         operationHistory.push(newOperation);
//         emit Calculation("Multiplication", inputs, result);
//         return result;
//     }
    
//     // Function to divide two numbers
//     function divide(uint256 a, uint256 b) public returns (uint256) {
//         require(b > 0, "Cannot divide by zero");
//         uint256 result = a / b;
        
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = a;
//         inputs[1] = b;
        
//         Operation memory newOperation = Operation({
//             functionName: "divide",
//             inputs: inputs,
//             result: result,
//             timestamp: block.timestamp,
//             caller: msg.sender
//         });
        
//         operationHistory.push(newOperation);
//         emit Calculation("Division", inputs, result);
//         return result;
//     }
    
//     // Function to get the total number of operations performed
//     function getOperationCount() public view returns (uint256) {
//         return operationHistory.length;
//     }
    
//     // Function to get operation details by index
//     function getOperation(uint256 index) public view returns (
//         string memory functionName,
//         uint256[] memory inputs,
//         uint256 result,
//         uint256 timestamp,
//         address caller
//     ) {
//         require(index < operationHistory.length, "Index out of bounds");
//         Operation memory op = operationHistory[index];
//         return (op.functionName, op.inputs, op.result, op.timestamp, op.caller);
//     }
    
//     // Function to get last n operations
//     function getLastNOperations(uint256 n) public view returns (Operation[] memory) {
//         require(n > 0, "N must be greater than 0");
//         uint256 start = operationHistory.length >= n ? operationHistory.length - n : 0;
//         uint256 length = operationHistory.length >= n ? n : operationHistory.length;
        
//         Operation[] memory lastOperations = new Operation[](length);
//         for (uint256 i = 0; i < length; i++) {
//             lastOperations[i] = operationHistory[start + i];
//         }
//         return lastOperations;
//     }
    
//     // Function to handle incoming ETH
//     receive() external payable {}
    
//     // Fallback function
//     fallback() external payable {}
// }




// SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;
pragma solidity ^0.8.7;


import {Chainlink, ChainlinkClient} from "@chainlink/contracts@1.2.0/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts@1.2.0/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts@1.2.0/src/v0.8/shared/interfaces/LinkTokenInterface.sol";



/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract LLMCaller is ChainlinkClient, ConfirmedOwner {

    using Chainlink for Chainlink.Request;


    uint256 private constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18
    string public responce;
    string [] public parsedRes;


    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0x9A57E62D53e17E8D6b1E288679d942F0AAfC9542);
        responce = "Hello";
    }


    event RequestLLMFullfilled(
        bytes32 indexed requestId,
        string value
    );


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
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }


    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }



    function fulfillLLM(
        bytes32 _requestId,
        string  memory _text
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestLLMFullfilled(_requestId, _text);
        responce = _text;

        string [] memory resultarray = parseAndStoreString(responce);
        // parsedRes = resultarray;

        callFunctionBasedonResponce(resultarray);

    }

    function requestLLM(
        address _oracle,
        string memory _jobId,
        string memory _prompt
    ) public onlyOwner {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfillLLM.selector
        );

        string memory formatedPrompt = "You are an AI agent capable of solving tasks by using a predefined set of tools. Your response must always be in the given format to ensure compatibility."
"The format for your responses should be as follows: functionname,functionargument1,functionargument2"
"Key guidelines: 1. Function Execution: When solving a task, choose the appropriate tool from the list provided to perform the task. 2. Response Format: Your response must include: - The name of the tool as \"functionName\". - All the required inputs as \"arguments\" . 3. Handling Missing Information: - If you cannot complete the task due to missing information, use the \"returnResult\" tool to explain why the task cannot be performed and request the missing details. - Example: \"I need the 'accountID' to complete this task.\""
    "4. Tool Selection: The tools you can use to solve the problems are listed below:"
     "A - functionname - checkBalance - it is used to check wallet balance of a blockchain wallet or details of a blockchin wallet. it needs the public address of the wallet as argument for function checkBalance. eg responce : - checkbalance,YOUR_WALLET_ADDRESS"
     "B - functionname - sum - it is used to sum two numbers. it will take two numbers as arguments. eg responce : - sum,first_number,second-number"
     "C - functionname - diff - it is used to get difference between two numbers. it will take two numbers as arguments. eg responce : - diff,first_number,second-number"
     "D - functionname - multpily - it is used to get prduct of two numbers. it will take two numbers as arguments. eg responce : - multiply,first_number,second-number"
     "E - functionname - divide - it is used to get division of two numbers. it will take two numbers as arguments. eg responce : - divide,first_number,second-number"
     "F - functionname - returnsResult - it is used to return your reason if all the other tools can not be used, or return answers for the questiom. eg : - responce : returnsResult,YOUR_RESPONCE"
    "6. Task Execution:"
       "- Only perform a task if explicitly asked to do so."
       "- If no specific task is mentioned or the provided information is insufficient, use the \"returnResult\" tool to provide feedback or ask clarifying questions."
    "7. Output Constraints: Always ensure that the output is:"
       "- Easily parsable."
       "- Properly formatted as array."
    "Remember to keep your responses structured, concise, and in the required JSON format for seamless integration."
    "the example resonce would be --  checkbalance,YOUR_WALLET_ADDESS "
    "The task i want you to do is \n";

    string memory finalPrompt = string.concat(formatedPrompt, _prompt);


        req._add("path", "candidates,0,content,parts,0,text");
        req._add("prompt", finalPrompt);


        _sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }



    function getChainlinkToken() public view returns (address) {
        return _chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(_chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        _cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    function callFunctionBasedonResponce(string[] memory res) public {

        if (compareStrings(res[0], "sum")) {
            uint256 one = stringToUint256(res[1]);
            uint256 two = stringToUint256(res[2]);
            sum(one, two);
        }
        else if (compareStrings(res[0], "diff")) {
            uint256 one = stringToUint256(res[1]);
            uint256 two = stringToUint256(res[2]);
            diff(one, two);
        }
        else if (compareStrings(res[0], "multiply")) {
            uint256 one = stringToUint256(res[1]);
            uint256 two = stringToUint256(res[2]);
            multiply(one, two);
        }
        else if (compareStrings(res[0], "divide\n")) {
            uint256 one = stringToUint256(res[1]);
            uint256 two = stringToUint256(res[2]);
            divide(one, two);
        }
        else if (compareStrings(res[0], "checkbalance")) {
            address addre = stringToAddress(res[1]);
            checkBalance(addre);
        }
   



    }


    struct Operation {
            string functionName;
            uint256[] inputs;
            uint256 result;
            uint256 timestamp;
            address caller;
        }

    // operations part
     // Array to store all operations
    Operation[] public operationHistory;
    
    // Events
    event Calculation(string operation, uint256[] inputs, uint256 result);
    event BalanceChecked(address account, uint256 balance);
    
    // Function to check balance of any address
    function checkBalance(address _address) public returns (uint256) {
        uint256 balance = _address.balance;
        
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = uint256(uint160(_address));
        
        Operation memory newOperation = Operation({
            functionName: "checkBalance",
            inputs: inputs,
            result: balance,
            timestamp: block.timestamp,
            caller: msg.sender
        });
        
        operationHistory.push(newOperation);
        emit BalanceChecked(_address, balance);
        return balance;
    }
    
    // Function to add two numbers
    function sum(uint256 a, uint256 b) public returns (uint256) {
        uint256 result = a + b;
        
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;
        
        Operation memory newOperation = Operation({
            functionName: "sum",
            inputs: inputs,
            result: result,
            timestamp: block.timestamp,
            caller: msg.sender
        });
        
        operationHistory.push(newOperation);
        emit Calculation("Addition", inputs, result);
        return result;
    }
    
    // Function to subtract two numbers
    function diff(uint256 a, uint256 b) public returns (uint256) {
        require(a >= b, "First number must be greater than or equal to second number");
        uint256 result = a - b;
        
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;
        
        Operation memory newOperation = Operation({
            functionName: "diff",
            inputs: inputs,
            result: result,
            timestamp: block.timestamp,
            caller: msg.sender
        });
        
        operationHistory.push(newOperation);
        emit Calculation("Subtraction", inputs, result);
        return result;
    }
    
    // Function to multiply two numbers
    function multiply(uint256 a, uint256 b) public returns (uint256) {
        uint256 result = a * b;
        
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;
        
        Operation memory newOperation = Operation({
            functionName: "multiply",
            inputs: inputs,
            result: result,
            timestamp: block.timestamp,
            caller: msg.sender
        });
        
        operationHistory.push(newOperation);
        emit Calculation("Multiplication", inputs, result);
        return result;
    }
    
    // Function to divide two numbers
    function divide(uint256 a, uint256 b) public returns (uint256) {
        require(b > 0, "Cannot divide by zero");
        uint256 result = a / b;
        
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = a;
        inputs[1] = b;
        
        Operation memory newOperation = Operation({
            functionName: "divide",
            inputs: inputs,
            result: result,
            timestamp: block.timestamp,
            caller: msg.sender
        });
        
        operationHistory.push(newOperation);
        emit Calculation("Division", inputs, result);
        return result;
    }
    
    // Function to get the total number of operations performed
    function getOperationCount() public view returns (uint256) {
        return operationHistory.length;
    }
    
    // Function to get operation details by index
    function getOperation(uint256 index) public view returns (
        string memory functionName,
        uint256[] memory inputs,
        uint256 result,
        uint256 timestamp,
        address caller
    ) {
        require(index < operationHistory.length, "Index out of bounds");
        Operation memory op = operationHistory[index];
        return (op.functionName, op.inputs, op.result, op.timestamp, op.caller);
    }
    
    // Function to get last n operations
    function getLastNOperations(uint256 n) public view returns (Operation[] memory) {
        require(n > 0, "N must be greater than 0");
        uint256 start = operationHistory.length >= n ? operationHistory.length - n : 0;
        uint256 length = operationHistory.length >= n ? n : operationHistory.length;
        
        Operation[] memory lastOperations = new Operation[](length);
        for (uint256 i = 0; i < length; i++) {
            lastOperations[i] = operationHistory[start + i];
        }
        return lastOperations;
    }
    
    // Function to handle incoming ETH
    receive() external payable {}
    
    // Fallback function
    fallback() external payable {}
}


