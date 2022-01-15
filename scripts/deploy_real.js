const hre = require("hardhat");
const libraries = require("../libraries");

async function main() {
  // const IterableMapping = await hre.ethers.getContractFactory(
  // "IterableMapping"
  // );

  // deploy libraries
  // itMaps = await IterableMapping.deploy();
  // await itMaps.deployed();
  // console.log(itMaps.address);

  // We get the contract to deploy
  const ENHANCE = await hre.ethers.getContractFactory("ENHANCE", {
    libraries: libraries,
  });
  const tryInstance = await ENHANCE.deploy();
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

  console.log("Verifying Token Contract");
  await hre.run("verify", {
    address: token,
    contract: "contracts/ENHANCE.sol:ENHANCE",
    libraries: "libraries.js",
  });

  console.log("Verifying DividendTracker Contract");
  await hre.run("verify", {
    address: dividendTracker,
    constructorArgsParams: [reward],
    contract: "contracts/DividendTracker.sol:DividendTracker",
    libraries: "libraries.js",
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
