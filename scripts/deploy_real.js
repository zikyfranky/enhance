const hre = require("hardhat");

async function main() {
  const IterableMapping = await hre.ethers.getContractFactory(
    "IterableMapping"
  );


  let itMaps; 
  try {
    itMaps = await IterableMapping.attach(
      "0x0355160615DD47C22b8f3a4eD8177Ce39a90cE83"
    );
  }catch(e){
    // deploy libraries
    itMaps = await IterableMapping.deploy();
    await itMaps.deployed();
  }

  // We get the contract to deploy
  const ENHANCE = await hre.ethers.getContractFactory("ENHANCE", {
    libraries:{
      IterableMapping: itMaps.address
    }
  });

  const tryInstance = await ENHANCE.deploy();

  await tryInstance.deployed();

  console.log("TRY deployed to:", tryInstance.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
