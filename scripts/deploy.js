const hre = require("hardhat");

async function main() {
  // We get the contract to deploy
  const TRY = await hre.ethers.getContractFactory("TRY");
  const tryInstance = await TRY.deploy("Hello, Hardhat!");

  await tryInstance.deployed();

  console.log("TRY deployed to:", tryInstance.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
