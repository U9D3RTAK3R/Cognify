# Manual Testing Walkthrough

This guide provides step-by-step instructions to set up the development environment and manually test the Cognify platform, specifically focusing on the new Client-Side Certificate Minting feature.

## Prerequisites
- **Go** (for Backend)
- **Flutter** (for Frontend)
- **Node.js & NPM** (for Blockchain)
- **MetaMask Browser Extension**

---

## 1. Blockchain Setup (Hardhat)

We need a local blockchain to simulate Ethereum.

1.  **Navigate to Blockchain Directory:**
    ```powershell
    cd blockchain
    ```

2.  **Start Hardhat Node:**
    This spins up a local blockchain at `http://127.0.0.1:8545` and gives you 20 test accounts with fake ETH.
    ```powershell
    npx hardhat node
    ```
    *Keep this terminal running.*

3.  **Deploy Smart Contract:**
    Open a **new terminal**.
    ```powershell
    cd blockchain
    npx hardhat run scripts/deploy.js --network localhost
    ```
    **Copy the deployed contract address** from the output (e.g., `0x5FbDB...`).

4.  **Configure MetaMask:**
    - Open MetaMask > Settings > Networks > **Add a network manually** (Do NOT use the default "Localhost 8545").
    - **Network Name:** Hardhat Local (Custom)
    - **RPC URL:** `http://127.0.0.1:8545` (Crucial: Use 127.0.0.1, NOT localhost)
    - **Chain ID:** `1337`
    - **Currency Symbol:** ETH
    - **Save** and switch to this network.
    - **Import Account:** Copy the private key of "Account 0" (Instructor) from the "Hardhat Node" terminal and import it into MetaMask.

---

## 2. Backend Setup (Go)

The backend handles API requests and prepares the certificate data.

1.  **Navigate to Backend Directory:**
    ```powershell
    cd backend
    ```

2.  **Configure Environment:**
    Ensure your `.env` or config has:
    ```env
    PLATFORM_SECRET=your_dev_secret_here
    ```

3.  **Run Backend:**
    ```powershell
    go run main.go
    ```
    The server should start on port `8080`.

---

## 3. Frontend Setup (Flutter)

The frontend interacts with the blockchain via MetaMask.

1.  **Navigate to Frontend Directory:**
    ```powershell
    cd frontend
    ```

2.  **Update Contract Address (If changed):**
    If your deployed contract address from Step 1.3 is different from the default, update it in:
    `frontend/lib/core/services/blockchain_service.dart` at line `_contractAddress`.

3.  **Run Flutter Web:**
    **Note:** Blockchain features **only work on Web**.
    ```powershell
    flutter run -d chrome --web-renderer html
    ```
    *Using `--web-renderer html` is recommended for better compatibility with some JS libraries, though CanvasKit is standard.*

---

## 4. Testing the Minting Flow

1.  **Login as Instructor:**
    - Use the Instructor Login flow in the app.
    - Ensure your MetaMask is connected to "Hardhat Local".

2.  **Navigate to Certificate Panel:**
    - Go to a Course > Issue Certificate.

3.  **Fill Certificate Details:**
    - **Student Wallet:** Use one of the *other* hardhat accounts (e.g., Account 1's public address).
    - **Name:** "Test Student"
    - **Marks:** 95

4.  **Mint:**
    - Click **"Mint Certificate"**.
    - **MetaMask Popup:** You should see a transaction request.
    - **Confirm:** Click "Confirm" in MetaMask.

5.  **Verify Success:**
    - You should see a success message with the **Transaction Hash** and **Academic DNA**.
    - **Check Hardhat Console:** You should see the transaction being mined in the Hardhat terminal.

## Troubleshooting

-   **MetaMask Error: Nonce too high**: Reset your MetaMask account transaction history (Settings > Advanced > Clear activity tab data). This happens when you restart the Hardhat node.
-   **"MetaMask not installed"**: Ensure you are running on Chrome and have the extension.
