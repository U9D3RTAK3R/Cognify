# Implementation Plan - Blockchain Certificate Minting Refactor

## Problem Description
The current implementation has a mismatch between requirements and code structure:
1.  **Requirement**: "Instructor will mint (issue) the certificate to the student's wallet address using metamask extension whose hash will be stored on the database and shown to the student and instructor and using which anyone can verify the authenticity of the certificate".
2.  **Current Code**: `GenerateCertificateHandler` in `instructor.go` performs server-side minting using a single server private key.
3.  **Redundancy**: `PrepareMintHandler` in `minting.go` exists but seems unused or separate from the main flow.
4.  **Missing Endpoint**: The frontend service references endpoints that might not be fully wired up for the correct flow.

## Goals
1.  Refactor the backend to support Client-Side (Instructor) Minting.
2.  Ensure the Blockchain Listener correctly indexes certificates minted by instructors.
3.  Clean up the API structure to avoid confusion between "Requesting a Mint" and "Minting".

## User Review Required
> [!IMPORTANT]
> **Breaking Change**: The `/api/instructor/certificate/generate` endpoint will no longer mint certificates directly. It will return the *metadata* (Academic DNA) and *authorization signature* needed for the frontend to perform the minting. Frontend code MUST be updated to handle the MetaMask transaction.

## Proposed Changes

### Backend (`backend/internal/api/`)

#### [MODIFY] [instructor.go](file:///d:/VS%20CODE%20PROGRAMS/Cognify/backend/internal/api/instructor.go)
- **Deprecate/Modify** `GenerateCertificateHandler`.
    - Change logic: Instead of calling `realClient.MintCertificate`, it should:
        1. Generate `AcademicDNA`.
        2. Sign the data with the Server's Private Key (to authorize the minting on the smart contract).
        3. Return the `AcademicDNA`, `Signature`, and `CertificateHash` to the frontend.
- Remove direct blockchain minting calls from this handler.

#### [MODIFY] [minting.go](file:///d:/VS%20CODE%20PROGRAMS/Cognify/backend/internal/api/minting.go)
- Review `PrepareMintHandler`. It actually implements the correct logic (DNA generation + Signing).
- **Proposal**: Merge logic. Use `PrepareMintHandler` as the standard for preparing a certificate. Ensure `instructor.go` uses this or routes conflicts are resolved.

#### [MODIFY] [blockchain/listener.go](file:///d:/VS%20CODE%20PROGRAMS/Cognify/backend/internal/blockchain/listener.go)
- Ensure `handleCertificateMinted` captures the `issuer` address.
- Verify that the `issuer` matches the Instructor's wallet address stored in Firestore (optional security check).

### Frontend (`frontend/lib/`)

#### [MODIFY] [core/services/blockchain_service.dart](file:///d:/VS%20CODE%20PROGRAMS/Cognify/frontend/lib/core/services/blockchain_service.dart)
- **Problem**: Currently acts as a facade. It calls `prepare` but mocks the actual blockchain transaction.
- **Change**:
    - Import the ABI for `SoulboundCertificateRegistry`.
    - Use `MetaMaskService` (or direct JS interop) to call the `mintCertificate` function on the smart contract.
    - **Function Signature**: `mintCertificate(bytes32 _certHash, address _owner, string _academicDNA)`.
    - Should wait for the transaction receipt or returns the hash immediately for tracking.

#### [MODIFY] [core/services/metamask_service.dart](file:///d:/VS%20CODE%20PROGRAMS/Cognify/frontend/lib/core/services/metamask_service.dart)
- Ensure it exposes a method to generic contract calls if not already present.
- Needs `sendTransaction` or `callContract` capability.

#### [MODIFY] [features/instructor/certificates/instructor_mint_certificate_panel.dart](file:///d:/VS%20CODE%20PROGRAMS/Cognify/frontend/lib/features/instructor/certificates/instructor_mint_certificate_panel.dart)
- Remove `mock_token`. Retrieve actual auth token from `AuthState` or `InstructorState`.
- Improve error handling to catch "User Rejected" or "RPC Error" explicitly.

### Smart Contract (`blockchain/contracts/CertificateRegistry.sol`)
- **Verify**: Ensure `mintCertificate` function is `public` (or `external`) and checks `onlyAuthorized`.
- **Action**: The Instructor's wallet address MUST be added to `authorizedIssuers` on the contract.
    - *Note*: We need an admin function or flow to authorize instructors when they sign up or get approved.

## Verification Plan

### Automated Tests
- **Backend**: Run unit tests for `PrepareMintHandler` to ensure it returns valid signatures.
- **Contract**: Run Hardhat tests to verify that an authorized address (simulated instructor) can mint.

### Manual Verification
1.  **Authorization**: Use the Owner account to `authorizeIssuer` (Instructor's Wallet).
2.  **Minting Flow**:
    - Log in as Instructor.
    - Go to Dashboard -> Issue Certificate.
    - Click "Issue".
    - **Expected**: Backend returns 200 OK with DNA. MetaMask popup appears.
    - Confirm Transaction in MetaMask.
    - **Expected**: Transaction succeeds.
3.  **Verification**:
    - Check Firestore: Certificate document should appear/update with `isMinted: true`.
    - Check Student Dashboard: Certificate should be visible.

## Development Environment Setup
### Starting Local Blockchain
To mint certificates using fake ETH for development:
1.  **Start Hardhat Node**:
    ```bash
    cd blockchain
    npx hardhat node
    ```
    This will spin up a local JSON-RPC server at `http://127.0.0.1:8545/` and give you 20 test accounts with 10000 ETH each.

2.  **Deploy Contract to Localhost**:
    Open a new terminal:
    ```bash
    cd blockchain
    npx hardhat run scripts/deploy.js --network localhost
    ```
    Note the deployed contract address.

3.  **Configure Backend**:
    Update `.env.blockchain` or `.env` with:
    ```
    BLOCKCHAIN_RPC_URL=http://127.0.0.1:8545/
    CONTRACT_ADDRESS=<DEPLOYED_ADDRESS>
    ```

4.  **Connect MetaMask**:
    - Add Network: "Localhost 8545" (Chain ID: 31337).
    - Import Account: Copy a Private Key from the `npx hardhat node` output and import it into MetaMask.
