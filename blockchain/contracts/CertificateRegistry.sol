// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CertificateRegistry
 * @dev Smart contract for soulbound (non-transferable) academic certificates
 * @notice Certificates are permanently bound to the owner's wallet address
 */
contract CertificateRegistry {
    
    // Certificate structure
    struct Certificate {
        bytes32 hash;           // SHA256 hash of certificate
        address owner;          // Wallet that owns this certificate (soulbound)
        address issuer;         // Address of certificate issuer
        uint256 timestamp;      // Block timestamp when minted
        string academicDNA;     // Academic DNA identifier (SHA256 hash)
        bool exists;            // Flag to check existence
        bool revoked;           // Flag for revocation (fraud cases)
    }
    
    // State variables
    mapping(bytes32 => Certificate) public certificates;
    mapping(address => bytes32[]) public walletCertificates;
    mapping(address => uint256) public issuerCertCount;
    uint256 public totalCertificates;
    
    // Owner for administrative functions
    address public owner;
    mapping(address => bool) public authorizedIssuers;
    
    // Events
    event CertificateMinted(bytes32 indexed certHash, address indexed owner, address indexed issuer);
    event CertificateRevoked(bytes32 indexed certHash, address indexed issuer, string reason);
    event IssuerAuthorized(address indexed issuer);
    event IssuerRevoked(address indexed issuer);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedIssuers[msg.sender] || msg.sender == owner, "Not authorized to mint");
        _;
    }
    
    /**
     * @dev Constructor sets the contract deployer as owner
     */
    constructor() {
        owner = msg.sender;
        authorizedIssuers[msg.sender] = true;
    }
    
    /**
     * @dev Mint a soulbound certificate to a specific wallet
     * @param _certHash SHA256 hash of the certificate
     * @param _owner Wallet address that will own this certificate
     * @param _academicDNA Academic DNA identifier for the certificate owner
     */
    function mintCertificate(bytes32 _certHash, address _owner, string calldata _academicDNA) external onlyAuthorized {
        require(_certHash != bytes32(0), "Invalid certificate hash");
        require(_owner != address(0), "Invalid owner address");
        require(!certificates[_certHash].exists, "Certificate already exists");
        
        certificates[_certHash] = Certificate({
            hash: _certHash,
            owner: _owner,
            issuer: msg.sender,
            timestamp: block.timestamp,
            academicDNA: _academicDNA,
            exists: true,
            revoked: false
        });
        
        walletCertificates[_owner].push(_certHash);
        issuerCertCount[msg.sender]++;
        totalCertificates++;
        
        emit CertificateMinted(_certHash, _owner, msg.sender);
    }
    
    /**
     * @dev Verify if a certificate exists and get its details
     * @param _certHash SHA256 hash to verify
     * @return exists Whether certificate exists
     * @return certOwner Address of the certificate owner
     * @return issuer Address of the issuer
     * @return timestamp When certificate was minted
     * @return academicDNA Academic DNA identifier
     * @return revoked Whether certificate has been revoked
     */
    function verifyCertificate(bytes32 _certHash) 
        external 
        view 
        returns (
            bool exists, 
            address certOwner, 
            address issuer, 
            uint256 timestamp,
            string memory academicDNA,
            bool revoked
        ) 
    {
        Certificate memory cert = certificates[_certHash];
        return (cert.exists, cert.owner, cert.issuer, cert.timestamp, cert.academicDNA, cert.revoked);
    }
    
    /**
     * @dev Get all certificate hashes for a wallet
     * @param _wallet Address to query
     * @return Array of certificate hashes owned by the wallet
     */
    function getCertificatesByWallet(address _wallet) 
        external 
        view 
        returns (bytes32[] memory) 
    {
        return walletCertificates[_wallet];
    }
    
    /**
     * @dev Get total number of certificates minted
     * @return Total certificate count
     */
    function getTotalCertificates() external view returns (uint256) {
        return totalCertificates;
    }
    
    /**
     * @dev Get number of certificates issued by an address
     * @param _issuer Address to check
     * @return Certificate count for issuer
     */
    function getIssuerCertCount(address _issuer) external view returns (uint256) {
        return issuerCertCount[_issuer];
    }
    
    /**
     * @dev Revoke a certificate (for fraud cases)
     * @param _certHash Hash of certificate to revoke
     * @param _reason Reason for revocation
     */
    function revokeCertificate(bytes32 _certHash, string calldata _reason) 
        external 
    {
        require(certificates[_certHash].exists, "Certificate not found");
        require(!certificates[_certHash].revoked, "Already revoked");
        
        // Allow contract owner OR the original issuer to revoke
        require(msg.sender == owner || msg.sender == certificates[_certHash].issuer, "Not authorized to revoke");
        
        certificates[_certHash].revoked = true;
        emit CertificateRevoked(_certHash, msg.sender, _reason);
    }
    
    /**
     * @dev Soulbound: Transfer is permanently disabled
     * @notice Certificates cannot be transferred to maintain academic integrity
     */
    function transfer(bytes32 /*_certHash*/, address /*_to*/) external pure {
        revert("Soulbound: Certificates are non-transferable");
    }
    
    /**
     * @dev Authorize an address to mint certificates
     * @param _issuer Address to authorize
     */
    function authorizeIssuer(address _issuer) external onlyOwner {
        require(_issuer != address(0), "Invalid address");
        require(!authorizedIssuers[_issuer], "Already authorized");
        
        authorizedIssuers[_issuer] = true;
        emit IssuerAuthorized(_issuer);
    }
    
    /**
     * @dev Revoke authorization from an issuer
     * @param _issuer Address to revoke
     */
    function revokeIssuer(address _issuer) external onlyOwner {
        require(authorizedIssuers[_issuer], "Not authorized");
        require(_issuer != owner, "Cannot revoke owner");
        
        authorizedIssuers[_issuer] = false;
        emit IssuerRevoked(_issuer);
    }
    
    /**
     * @dev Transfer ownership to a new address
     * @param _newOwner New owner address
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
        authorizedIssuers[_newOwner] = true;
    }
}
