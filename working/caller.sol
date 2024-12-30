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



    function fulfillLLM(
        bytes32 _requestId,
        string  memory _text
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestLLMFullfilled(_requestId, _text);
        responce = _text;
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
}