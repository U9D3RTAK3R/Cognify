# Task Checklist: Blockchain Certificate Minting Refactor

- [ ] **Phase 1: Analysis & Documentation** <!-- id: 0 -->
    - [x] Analyze existing project structure and identify issues <!-- id: 1 -->
    - [x] Create implementation plan <!-- id: 2 -->
    - [ ] **Setup Local Blockchain**: <!-- id: 20 -->
        - [ ] Start Hardhat Node (`npx hardhat node`). <!-- id: 21 -->
        - [ ] Deploy contract to localhost (`npx hardhat run scripts/deploy.js --network localhost`). <!-- id: 22 -->
        - [ ] Configure Backend/Frontend with local contract address & RPC. <!-- id: 23 -->

- [x] **Phase 2: Backend Refactoring** <!-- id: 3 -->
    - [x] Update `GenerateCertificateHandler` in `backend/internal/api/instructor.go` to remove server-side minting. <!-- id: 4 -->
    - [x] Rename/Refactor `GenerateCertificateHandler` to `RequestCertificateMinting` (or similar) which prepares the metadata and returns `academicDNA`. <!-- id: 5 -->
    - [x] Ensure `PrepareMintHandler` in `backend/internal/api/minting.go` is integrated or merged with the above. <!-- id: 6 -->
    - [x] Verify `listener.go` correctly indexes `CertificateMinted` events from arbitrary instructor addresses (if authorized). <!-- id: 7 -->


- [x] **Phase 3: Frontend Implementation** <!-- id: 8 -->
    - [x] **Fix `BlockchainService` (Critical)**: <!-- id: 9 -->
        - [x] Remove mock transaction logic in `mintCertificate`. <!-- id: 10 -->
        - [x] Implement actual Smart Contract call using `web3dart` or JS Interop. <!-- id: 11 -->
        - [x] Requires ABI for `SoulboundCertificateRegistry`. <!-- id: 12 -->
    - [x] Update `InstructorMintCertificatePanel`: <!-- id: 13 -->
        - [x] Remove hardcoded tokens. <!-- id: 14 -->
        - [x] enhanced error handling for Metamask rejections. <!-- id: 15 -->
    - [x] Verify `MetaMaskService` supports contract method calls (currently only supports signing). <!-- id: 16 -->


- [ ] **Phase 4: Smart Contract Verification (Optional)** <!-- id: 14 -->
    - [ ] Ensure Smart Contract `mintCertificate` allows authorized instructors (not just the owner) to mint. <!-- id: 15 -->
    - [ ] Verify existing `CertificateRegistry.sol` logic covers this. <!-- id: 16 -->

- [ ] **Phase 5: Verification & Testing** <!-- id: 17 -->
    - [ ] Test entire flow: Instructor Login -> Prepare Mint -> MetaMask Sign -> Blockchain Mint -> Backend Indexing. <!-- id: 18 -->
    - [ ] Verify Certificate shows up in Student Dashboard. <!-- id: 19 -->
