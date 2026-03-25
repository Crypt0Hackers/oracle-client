// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MockOracle.sol";
import "../src/DataConsumerV3.sol";

contract MockOracleTest is Test {
    
    MockOracle public oracle;
    DataConsumerV3 public consumer;

    function setUp() public {
        //1. deploys the mock oracle address
        oracle = new MockOracle();
        //2. pass it's to address DataConsumerV3
        consumer = new DataConsumerV3(address(oracle));
    }

    function testInitialPrice() public view {
        // MockOracle initialses at $2000
        int256 answer = consumer.getChainlinkDataFeedLatestAnswer();
        assertEq(answer, 200000000000);
    }

    function testPriceUpdates() public {
        // Update the oracle to $3000
        oracle.updateAnswer(300000000000);

        // Consumer should now reflect the new price
        int256 answer = consumer.getChainlinkDataFeedLatestAnswer();
        assertEq(answer, 300000000000);
    }  
}