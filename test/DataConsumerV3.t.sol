// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MockOracle.sol";
import "../src/DataConsumerV3.sol";

contract DataConsumerV3Test is Test {

    MockOracle public oracle;
    DataConsumerV3 public consumer;

    function setUp() public {
        // Deploy MockOracle (initializes with $2000) and pass it to DataConsumerV3
        oracle = new MockOracle();
        consumer = new DataConsumerV3(address(oracle));
    }

    function testLatestAnswer() public view {
        int256 answer = consumer.getChainlinkDataFeedLatestAnswer();
        // MockOracle initializes at $2000 (200000000000 with 8 decimals)
        assertEq(answer, 200000000000);
    }

    function testAnswerUpdatesAfterOracleUpdate() public {
        oracle.updateAnswer(250000000000); // $2500
        int256 answer = consumer.getChainlinkDataFeedLatestAnswer();
        assertEq(answer, 250000000000);
    }
}

contract DataConsumerV3ForkTest is Test {

    DataConsumerV3 public consumer;

    // Real Chainlink ETH/USD feed on Ethereum mainnet
    address constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function setUp() public {
        consumer = new DataConsumerV3(ETH_USD_FEED);
    }

    function testLiveFeed() public view {
        int256 answer = consumer.getChainlinkDataFeedLatestAnswer();
        // Price should be a realistic ETH price (greater than 0)
        assertGt(answer, 0);
    }
}
