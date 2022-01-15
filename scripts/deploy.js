const hre = require("hardhat");

async function main() {
  const IterableMapping = await hre.ethers.getContractFactory(
    "IterableMapping"
  );

  // deploy libraries
  // itMaps = await IterableMapping.deploy();
  // await itMaps.deployed();

  // We get the contract to deploy
  const TRY_FINAL = await hre.ethers.getContractFactory("TRY_FINAL", {
    libraries: {
      IterableMapping: "0x0355160615DD47C22b8f3a4eD8177Ce39a90cE83",
    },
  });

  const tryInstance = await TRY_FINAL.deploy();

  await tryInstance.deployed();

  console.log("TRY_FINAL deployed to:", tryInstance.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
