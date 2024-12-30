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


    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0x9A57E62D53e17E8D6b1E288679d942F0AAfC9542);
        responce = "Hello";
    }


    event RequestLLMFullfilled(
        bytes32 indexed requestId,
        string value
    );





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

        callFunctionBasedonResponce(_text);

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
        req._add("path", "candidates,0,content,parts,0,text");
        req._add("prompt", _prompt);


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

    function callFunctionBasedonResponce(string memory functionName) public {

        if (compareStrings(functionName, "sum\n")) {
            sum(1873, 628);
        }
        else if (compareStrings(functionName, "diff\n")) {
            diff(10000,2222);
        }
        else if (compareStrings(functionName, "multiply\n")) {
            multiply(2, 15);
        }
        else if (compareStrings(functionName, "divide\n")) {
            divide(1000, 20);
        }
        else if (compareStrings(functionName, "checkbalance\n")) {
            checkBalance(0x5416A1B78E89d891018570CDbdD4954c31e52D6e);
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