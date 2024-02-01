// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {DecentralizedFundrasingPlatform} from "../src/DFP.sol";

contract DFPTest is Test {

	bytes public name = "charity";
	string public description = "this is for the charity purpose";
	uint public deadline = 2 minutes;
	uint public targetAmount = 1 ether;
	address public one = 0xE6c9b90783e19354C4CE8c33686e91c6587CA876;
	uint public PRECISION = 1e18;
	event CampaignCreation(
        uint indexed camapaignId,
        address indexed creator,
        uint indexed targetAmount,
        uint deadline
    );
	 event Contribution(
        uint indexed camapaignId, 
        address indexed contributor, 
        uint indexed amount
    );
    event RefundClaim(
        uint indexed camapaignId, 
        address indexed contributor, 
        uint indexed amount
    ); 
    event CampaignCompleted(
        uint indexed camapaignId, 
        address indexed administrator, 
        uint indexed amount
    ); 

	DecentralizedFundrasingPlatform dfp;
	function setUp() public {
		dfp = new DecentralizedFundrasingPlatform();
	}

	receive() external payable {}

	function test_AddCampaign() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
	}
	function test_RevertWhenPresentTimeGiven() public {
		vm.expectRevert(bytes("Deadline Must Be Greater Present Time"));
		dfp.addCompaign(name,description,targetAmount,block.timestamp);
	}
	function test_RevertWhenEnterAmountZero() public {
		vm.expectRevert();
		dfp.addCompaign(name,description,0,deadline);
	}

	function test_EventEmitionOfCampaignCreation() public {
		vm.expectEmit(true,true,true,true);
		vm.startPrank(msg.sender);
		emit CampaignCreation(1,msg.sender,targetAmount,deadline);
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.stopPrank();
	}

	function test__RevertBeforeCampaignCannotFund() external {
		vm.expectRevert(DecentralizedFundrasingPlatform.DFP__FundRaisingNotActive.selector);
		dfp.fundComapign(1,2000000000000000000);
	}

	function test__FundCampaign() public {
		test_AddCampaign();
		dfp.fundComapign{value:2000000000000000000 }(1,2000000000000000000);
	}
	function test__RevertOnlyFunderCanWithdraw() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.startPrank(one);
		dfp.fundComapign(1,2000000000000000000);
		vm.stopPrank();
		vm.expectRevert(bytes("First Contribute"));
		vm.warp(deadline + 1 minutes);
		dfp.refund(1);
	}

	function test_RevertCannotWithDrawBeforeDeadline() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.fundComapign(1,2);
		vm.expectRevert(abi.encodeWithSelector(DecentralizedFundrasingPlatform.DFP__FundRaisingIsEnded.selector));
		dfp.refund(1);
	}

	function test__FundSpecificCampaign() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.fundComapign(1,5);
		dfp.fundComapign(2,10);
		assertEq(dfp.getAmountReceived(1),5);
		assertEq(dfp.getAmountReceived(2),10);
	}

	function test__RevertComapignIsNotActive() external {
		vm.expectRevert(DecentralizedFundrasingPlatform.DFP__FundRaisingNotActive.selector);
		dfp.fundComapign(1,10);
	}
	function test__RevertCannotFundZeroAmount() external {
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.expectRevert(DecentralizedFundrasingPlatform.DFP__NeedsValueMoreThanZero.selector);
		dfp.fundComapign(1,0);
	}

	function test__EventEmittionOnFunding() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.prank(msg.sender);
		vm.expectEmit(true, true, true, true);
		emit Contribution(1,msg.sender,5);
		dfp.fundComapign(1,5);
	}

	function test__RevertWhenTargetAmountMet() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.startPrank(msg.sender);
		dfp.fundComapign(1, targetAmount);
		vm.expectRevert(DecentralizedFundrasingPlatform.DFP__TargetAmountReachedCannotRefund.selector);
		vm.warp(deadline + 1 days);
		dfp.refund(1);
		vm.stopPrank();
	}

	function test__Refund() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		deal(msg.sender,0.5 * 1e18);
		dfp.fundComapign{value : 0.5 * 1e18}(1, 0.5 * 1e18);
		vm.warp(deadline + 1 days);
		dfp.refund(1);

	}


	function test__RevertOnlyOwnerCanCompleteCampaign() external {
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.startPrank(msg.sender);
		dfp.fundComapign(1, targetAmount);
		vm.expectRevert(DecentralizedFundrasingPlatform.DFP__OnlyAdministratorCanPerfromThis.selector);
		vm.warp(deadline + 1 days);
		dfp.completeCampaign(1);
		vm.stopPrank();
	}

	function test__ContractBalanceChecking() external {
		dfp.addCompaign(name,description,targetAmount,deadline);
		// vm.prank(one);
		// vm.deal(one,2 ether);
		hoax(msg.sender,1);
		dfp.fundComapign{value: 1}(1, 1 );
		assertEq(address(dfp).balance ,1);
	}

	function test__CompleteCampaign() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		deal(msg.sender, 1 ether);
		dfp.fundComapign{value: 1 ether}(1,1 ether);
		vm.warp(deadline + 1 days);
		dfp.completeCampaign(1);
	}

	function test__transferRefund() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		hoax(one, 0.5 ether);
		dfp.fundComapign{value: 0.5 ether}(1,0.5 ether);
		hoax(address(1), 0.1 ether);
		dfp.fundComapign{value: 0.1 ether}(1,0.1 ether);
		vm.warp(deadline + 1 days);
		dfp.transferRefund(1);
	}

	function test__RevertOnlyOwnerCantransferRefund() public {
		dfp.addCompaign(name,description,targetAmount,deadline);
		hoax(one, 0.5 ether);
		dfp.fundComapign{value: 0.5 ether}(1,0.5 ether);
		hoax(address(1), 0.1 ether);
		dfp.fundComapign{value: 0.1 ether}(1,0.1 ether);
		vm.warp(deadline + 1 days);
		vm.prank(one);
		vm.expectRevert(DecentralizedFundrasingPlatform.DFP__OnlyAdministratorCanPerfromThis.selector);
		dfp.transferRefund(1);
	}



	function test__GetAllCampaign() external {
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.addCompaign(name,description,targetAmount,deadline);
		// vm.prank(msg.sender);
		// dfp.fundComapign{value: 2 ether}(1, 2);
		// vm.prank(one);
		// dfp.fundComapign{value: 2 ether}(1, 2);
		// vm.prank(address(3));
		// dfp.fundComapign{value: 2 ether}(1, 2);
		assertEq(dfp.getTotalComapaign(), 3);

	}

	function test__GetAllContributors() external {
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.addCompaign(name,description,targetAmount,deadline);
		dfp.addCompaign(name,description,targetAmount,deadline);
		vm.prank(msg.sender);
		dfp.fundComapign(1, 2);
		vm.prank(one);
		dfp.fundComapign(1, 2);
		vm.prank(address(3));
		dfp.fundComapign(1, 2);
		(address[] memory a , ) = dfp.getAllContributors(1);
		(address[] memory c , ) = dfp.getAllContributors(2);
		(address[] memory e , ) = dfp.getAllContributors(3);
		assertEq(a.length, 3);
		assertEq(c.length, 0);
		assertEq(e.length, 0);
		

	}



	function testFund(uint64 amount , uint target) public {
		vm.assume(target > 0);
		dfp.addCompaign(name,description,target,deadline);
		vm.assume(amount>0);
		dfp.fundComapign(1, amount);
	}

	function invariant__test() public {
		assertEq(address(dfp).balance,0);
	}


}