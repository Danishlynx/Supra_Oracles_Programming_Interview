# MyTokenSale Contract Overview

The "MyTokenSale" contract is designed to facilitate a token sale with both a presale and public sale phase. The contract inherits from the ERC20 standard, enabling the creation and management of a custom token. Key features and functionality include:

- **Presale and Public Sale Phases:** The contract supports two sale phases: presale and public sale. The owner of the contract can start these phases, specifying the maximum cap and duration for each. The presale phase must end before the public sale can begin.

- **Contribution Limits:** Users can buy tokens by sending Ether to the contract. Contributions are subject to individual limits defined by the "minContribution" and "maxContribution" parameters set during contract deployment. Users must contribute within these limits.

- **Token Minting:** When users contribute Ether, the contract mints tokens at a fixed rate of 10 tokens per Ether. The minted tokens are transferred to the contributor's address, and their contribution is tracked.

- **Cap Management:** The contract keeps track of the total Ether raised during both the presale and public sale phases. It ensures that the caps for each phase are not exceeded. If the cap is reached, contributions are no longer accepted.

- **Token Distribution:** The owner can distribute tokens manually to specified addresses using the "distributeTokens" function.

- **Refund Mechanism:** After the sale phases have ended, users can claim refunds if the minimum cap is not reached. Refunds are issued for the contributions made by each user during the sale phases. Users can only claim refunds when the sale phases are no longer active.

- **Events:** The contract emits events for various actions, such as contributions, token distributions, and refunds, providing transparency and traceability of contract activities.

The contract ensures a controlled and secure token sale process, with well-defined caps, contribution limits, and a refund mechanism in case the minimum cap is not reached. Users can participate in the sale by sending Ether, and the contract mints and distributes tokens accordingly. The owner has full control over starting and ending sale phases, distributing tokens, and monitoring the contract's status.

![Screenshot 2024-01-14 010245](https://github.com/Danishlynx/Supra_Oracles_Programming_Interview/assets/69537135/3ae06259-95d7-4312-a04c-b5457be3a73f)
![Screenshot 2024-01-14 010222](https://github.com/Danishlynx/Supra_Oracles_Programming_Interview/assets/69537135/c84a73c4-a2cf-4bce-9c30-90b4202f9bb7)

