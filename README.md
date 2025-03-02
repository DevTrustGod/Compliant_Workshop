# Compliant KYC Token

## Description
The **Compliant KYC Token** is a privacy-preserving, KYC-enforced digital asset built on Aleo. It integrates regulatory compliance features while ensuring on-chain privacy through zero-knowledge proofs. The token requires users to undergo KYC verification before they can receive and transfer tokens, preventing unauthorized transactions and enforcing spending limits.

## How It Works
The smart contract enforces KYC compliance through the following mechanisms:

1. **KYC Registration**: Only the admin can register users in the KYC registry, ensuring only verified users can transact.
2. **Token Initialization**: The token is registered with the Aleo token registry and set to require external authorization.
3. **Minting**: The admin mints a predefined token supply.
4. **Spending Limits**: Each user has a daily transaction cap to prevent excessive spending.
5. **Private Transfers**: Transactions are conducted using privacy-preserving techniques, with enforced KYC checks and spending limits.
6. **Epoch-based Compliance**: Transfers are validated against blockchain epochs to maintain time-based spending restrictions.

## Deployment Instructions

### Prerequisites
Ensure you have the following installed:
- [Aleo CLI](https://github.com/AleoHQ/leo) for compiling and deploying the program
- A local Aleo development network or access to the Aleo testnet
- A funded Aleo account with admin privileges

### Steps
1. **Clone the Repository**
   ```sh
   git clone https://github.com/devtrustgod/compliant_kyc_token.git
   cd compliant_kyc_token
   ```
2. **Build the Project**
   ```sh
   leo build
   ```
3. **Deploy the Contract**
   ```sh
   leo deploy
   ```
4. **Initialize the Token**
   ```sh
   leo run initialize
   ```
5. **Register a User's KYC**
   ```sh
   leo run register_kyc <user_address>
   ```
6. **Mint Tokens**
   ```sh
   leo run mint_private
   ```
7. **Issue a Spending Limit**
   ```sh
   leo run issue_limit <user_address>
   ```
8. **Transfer Tokens (KYC Verified Users Only)**
   ```sh
   leo run transfer_private <input_token> <spend_limit> <amount> <recipient> <epoch>
   ```

This ensures a fully compliant, privacy-focused token system on Aleo.

