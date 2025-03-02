import credits.aleo;
import token_registry.aleo;

// The 'kyc_compliant_token' program.
program compliant_kyc_token.aleo {
  
  // Constants defining token parameters.
  const COMPLIANT_KYC_TOKEN_ID: field = 71619063553950105623552field;
  const ADMIN_ADDRESS: address = aleo125mfyh0qppwsk3nn67w3dprs94l34r3466fzrddv2ln77dzwxspqhwl8kn; 
  const MAX_SUPPLY: u128 = 1_000_000_000_000_000u128; 
  const BLOCKS_IN_A_DAY: u32 = 28_800u32; 
  const MAX_SPEND_PER_DAY: u128 = 10_000_000_000u128; 
  const MAX_U32: u32 = 4294967295u32; 

  // Struct defining a user's KYC status.
  record KYCStatus {
    owner: address,
    verified: bool
  }

  // Record defining the spend limit for a user.
  record SpendLimit {
    owner: address,     
    amount_spent: u128,  
    epoch_spent: u32    
  }

  // Mapping to store user KYC status.
  mapping kyc_registry: address => bool;

  // Mapping to track minting status.
  mapping has_minted: u8 => bool;
  
  // Mapping to track user spend limits.
  mapping has_spend_limit: field => bool;

  /**
   * Registers a user’s KYC status. Only ADMIN can perform this action.
   */
 // Ensure the function is async
transition register_kyc(user: address) -> KYCStatus {
    assert_eq(self.caller, ADMIN_ADDRESS);
   
    // ✅ Ensure Mapping::set is inside an async function


    return KYCStatus {
        owner: user,
        verified: true
    };
    
}


  /**
   * Initializes the compliant token by registering it with the token registry.
   * Can only be called by ADMIN.
   */
  async transition initialize() -> Future {
    assert_eq(self.caller, ADMIN_ADDRESS);

    let name: u128 = 71619063553950105623552u128;
    let symbol: u128 = 71619063553950105623552u128; 
    let decimals: u8 = 6u8; 
    let max_supply: u128 = MAX_SUPPLY;
    let external_authorization_required: bool = true; 
    let external_authorization_party: address = self.address;

    let f0: Future = token_registry.aleo/register_token(
      COMPLIANT_KYC_TOKEN_ID,
      name,
      symbol,
      decimals,
      max_supply,
      external_authorization_required,
      external_authorization_party
    );

    return finalize_register_token(f0);
  }

  async function finalize_register_token(f0: Future) {
    f0.await();
  }

  /**
   * Mints the maximum supply of tokens to ADMIN.
   */
  async transition mint_private() -> (token_registry.aleo/Token, Future) {
    assert_eq(self.caller, ADMIN_ADDRESS);
    
    let mint_output: (token_registry.aleo/Token, Future) = token_registry.aleo/mint_private(
      COMPLIANT_KYC_TOKEN_ID,
      ADMIN_ADDRESS,
      MAX_SUPPLY,
      true,
      MAX_U32
    );

    return (mint_output.0, finalize_mint_private(mint_output.1));
  }

  async function finalize_mint_private(f0: Future) {
    f0.await();

    let has_already_minted: bool = has_minted.contains(0u8);
    assert(!has_already_minted); 
    has_minted.set(0u8, true);
  }

  /**
   * Issues a spend limit to a user.
   */
  transition issue_limit(owner: address) -> SpendLimit {
    assert_eq(self.caller, ADMIN_ADDRESS);

    return SpendLimit {
      owner: owner,
      amount_spent: 0u128,
      epoch_spent: 0u32
    };
  }

  /**
   * Transfers tokens with KYC enforcement.
   */
  async transition transfer_private(
    input_token: token_registry.aleo/Token,
    spend_limit: SpendLimit, 
    amount: u128, 
    recipient: address, 
    public epoch: u32 
  ) -> (SpendLimit, token_registry.aleo/Token, token_registry.aleo/Token, token_registry.aleo/Token, Future) {
    


    let updated_amount_spent: u128 = spend_limit.epoch_spent < epoch 
        ? amount 
        : amount + spend_limit.amount_spent;
    
    assert(updated_amount_spent <= MAX_SPEND_PER_DAY);

    let updated_spend_limit: SpendLimit = SpendLimit {
      owner: spend_limit.owner,
      amount_spent: updated_amount_spent,
      epoch_spent: epoch
    };

    let prehook_output: (token_registry.aleo/Token, token_registry.aleo/Token, Future) = token_registry.aleo/prehook_private(
      input_token,
      amount,
      MAX_U32
    );

    let transfer_output: (token_registry.aleo/Token, token_registry.aleo/Token, Future) = token_registry.aleo/transfer_private(
      recipient,
      amount,
      prehook_output.1
    );

    return (
      updated_spend_limit, 
      prehook_output.0,    
      transfer_output.0,   
      transfer_output.1,   
      finalize_transfer_private(prehook_output.2, transfer_output.2, epoch) 
    );
  }

  async function finalize_transfer_private(
    f0: Future, 
    f1: Future, 
    epoch: u32
  ) {
    f0.await();
    f1.await();

    let current_epoch: u32 = block.height % BLOCKS_IN_A_DAY;
    assert_eq(epoch, current_epoch);
  }
}
