const hre = require("hardhat");
const libraries = require("../libraries");

async function main() {


  const token = "0xa001862ba0866ee3e3a2613fab5954861452b9bf";
  const dividendTracker = "0xD4A210030B71Bb03FA85F8c72918078f1C185773";
//   const pair = await enhInstance.swapPair();
//   const router = await enhInstance.swapRouter();
//   const iterableMapping = libraries.IterableMapping;
  const reward = "0x42981d0bfbAf196529376EE702F2a9Eb9092fcB5";


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
