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
  const TRY_V2 = await hre.ethers.getContractFactory("TRY_V2", {
    libraries: libraries,
  });
  const tryInstance = await TRY_V2.deploy();
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
    contract: "contracts/TRYV2.sol:TRYV2",
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
