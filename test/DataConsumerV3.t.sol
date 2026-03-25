// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MockOracle.sol";
import "../src/DataConsumerV3.sol";

contract DataConsumerV3Test is Test {

    DataConsumerV3 public consumer;

    //Real Chainlink ETH/USD feed on Ethereum mainnet
    address constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    
    function setUp() public {
        //2. pass it's to address DataConsumerV3
        consumer = new DataConsumerV3(ETH_USD_FEED);
    }

    function testLiveFeed() public view {
        int256 answer = consumer.getChainlinkDataFeedLatestAnswer();
        //Price should be a realistic ETH price (greater than 0)
        assertGt(answer, 0);
    }  
}
