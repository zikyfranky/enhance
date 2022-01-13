require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");

module.exports = {
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    bscscan: process.env.BSC_API_KEY,
    etherscan: process.env.ETH_API_KEY,
  },
  networks: {
    //GANACHE NETWORK
    ganache: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 7545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
    },

    // ETHEREUM TESTNET
    eth_test: {
      provider: () =>
        new HDWalletProvider(
          process.env.ETH_SEED_PHRASE || process.env.ETH_PRIVATE_KEY,
          `https://ropsten.infura.io/v3/${process.env.INFURA_PROJECT_ID}`
        ),
      network_id: 3, // Ropsten's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 500, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },

    // ETHEREUM MAINNET
    eth_main: {
      provider: () =>
        new HDWalletProvider(
          process.env.ETH_SEED_PHRASE || process.env.ETH_PRIVATE_KEY,
          `https://ropsten.infura.io/v3/${process.env.INFURA_PROJECT_ID}`
        ),
      network_id: 1, // Mainnet's id
      gas: 1000000, // Mainnet has a higher block limit than ropsten
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 500, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true, // Skip dry run before migrations? (default: false for public nets )
    },

    //BINANCE SMART CHAIN TESTNET
    bsc_test: {
      provider: () =>
        new HDWalletProvider(
          process.env.BSC_SEED_PHRASE || process.env.BSC_PRIVATE_KEY,
          `https://data-seed-prebsc-1-s1.binance.org:8545`
        ),
      network_id: 97,
      confirmations: 2,
      timeoutBlocks: 500,
      skipDryRun: true,
    },

    //BINANCE SMART CHAIN MAINNET
    bsc_main: {
      provider: () =>
        new HDWalletProvider(
          process.env.BSC_SEED_PHRASE || process.env.BSC_PRIVATE_KEY,
          `https://bsc-dataseed1.binance.org`
        ),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.10", // Fetch exact version from solc-bin (default: truffle's version)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};
