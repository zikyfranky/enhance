require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);

  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    //BINANCE SMART CHAIN TESTNET
    bsc_test: {
      url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
      accounts: [process.env.BSC_PRIVATE_KEY],
      chainId: 97,
    },

    //BINANCE SMART CHAIN MAINNET
    bsc_main: {
      url: `https://bsc-dataseed1.binance.org`,
      accounts: [process.env.BSC_PRIVATE_KEY],
      chainId: 56,
    },
  },
  solidity: {
    version: "0.8.11",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },

  etherscan: {
    apiKey: process.env.BSC_API_KEY,
  },
};
