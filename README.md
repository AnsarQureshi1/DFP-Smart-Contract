# Decentralized Fundraising Platform (DFP) Smart Contract

## Overview

The Decentralized Fundraising Platform (DFP) Smart Contract is an Ethereum-based contract that facilitates decentralized fundraising campaigns. Contributors can fund campaigns, and when the campaign deadline is reached, funds are either transferred to the campaign creator or refunded to contributors, based on the campaign's success.

## Features

- **Campaign Creation:** Create fundraising campaigns by providing campaign details such as name, description, target amount, and deadline.
  
- **Campaign Funding:** Contributors can fund campaigns using ETH, and their contributions are recorded.

- **Refunds:** If the campaign target amount is not reached by the deadline, contributors can claim a refund.

- **Campaign Completion:** The administrator can complete a campaign after the deadline, transferring funds to the creator if the target amount is reached.

## Smart Contract Details

### Contracts

- `DecentralizedFundraisingPlatform.sol`: Main DFP contract managing campaign creation, funding, refunds, and completion.

### How to Use

1. **Create a Campaign:**
   - Use the `addCompaign` function to create a new fundraising campaign. Provide the campaign name, description, target amount, and deadline.

2. **Fund a Campaign:**
   - Contribute to a campaign using the `fundComapign` function, specifying the campaign ID and the amount to contribute.

3. **Claim Refund:**
   - If the campaign target amount is not reached, contributors can claim a refund using the `refund` function.

4. **Complete a Campaign:**
   - The administrator can complete a campaign using the `completeCampaign` function after the deadline.

5. **Get Campaign Information:**
   - Retrieve campaign details, contributors, and amounts using various view functions.

### Testing

This smart contract has been thoroughly tested using the Foundry testing framework to ensure its functionality and security.

### Security

- The smart contract has undergone security audits to identify and address vulnerabilities.


## License

This project is licensed under the [UNLICENSED License](LICENSE).

---

Feel free to customize the sections based on your specific details, such as contract deployment addresses, developer information, and licensing.