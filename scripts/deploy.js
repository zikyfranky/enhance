const hre = require("hardhat");
const libraries = require("../libraries");

async function main() {

  // We get the contract to deploy
  const TRYV2 = await hre.ethers.getContractFactory("TRYV2", {
    libraries: libraries,
  });
  const tryInstance = await TRYV2.deploy();
  await tryInstance.deployed();

  const token = tryInstance.address;
  const dividendTracker = await tryInstance.dividendTracker();
  const pair = await tryInstance.swapPair();
  const router = await tryInstance.swapRouter();
  const iterableMapping = libraries.IterableMapping;
  const reward = await tryInstance.REWARD();

  console.log("Token", token);
  console.log("DividendTracker", dividendTracker);
  console.log("Pair", pair);
  console.log("Router", router);
  console.log("IterableMapping", iterableMapping);
  console.log("RewardToken", reward);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
