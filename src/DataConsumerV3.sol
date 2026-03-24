// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DataConsumerV3 {
    AggregatorV3Interface internal dataFeed; //initializes the dataFeed variable as the AggregatorV3Interface interface type. This object can only be accessed within the curerent contract and contracts that inherit from it.

    constructor() {
        dataFeed = AggregatorV3Interface(0x5FbDB2315678afecb367f032d93F642f64180aa3); //creates interface object by pointing to the Mock Oracle contract which acts as the aggregator
}

    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {// view function that doesn't alter the state hence doesn't use gas
        (,int256 answer,,,) = dataFeed.latestRoundData(); // returns five values representing information about the latest price data. 
        return answer;
    }
}