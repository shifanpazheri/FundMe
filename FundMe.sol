// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PriceConvertor.sol";

error NotOwner();

contract FundMe{

    uint256 public constant MINIMUM_USD=50*1e18;
    
    address[] public funders;
    mapping(address=>uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor(){
        i_owner=msg.sender;
    }

    function fund() public payable{
        //msg.value in wei
        //PriceConvertor.getConversionRate(msg.value);
        require(PriceConvertor.getConversionRate(msg.value)>MINIMUM_USD,"Didn't have enough money");
        //require(msg.value.getConversionRate()>minimumUSD,"Didn't have enough money");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender]=msg.value;
    }

    function withdraw() public onlyOwner{

        for(uint256 i=0;i<funders.length;i++){
            address funder=funders[i];
            addressToAmountFunded[funder]=0;
        }
        //reset the array
        funders=new address[](0);
        (bool sucessCall,)=payable(msg.sender).call{value:address(this).balance}("");
        require(sucessCall,"Call failed!");
    }

    modifier onlyOwner{
        //require(msg.sender==i_owner,"Sender is not owner");
        if(msg.sender!=i_owner){
            revert NotOwner();
        }
        _;
    }

    //what if someone send this contract money without calling fund function
    receive() external payable{
        fund();
    }

    //what if someone send this contract money without calling fund function
    fallback() external payable{
        fund();
    }

}
