import { ethers } from "hardhat";

async function main() {
  
  const Twitter = await ethers.deployContract("Twitter");

  await Twitter.waitForDeployment();

  console.log(
    `Twitter has been deployed to ${Twitter.target}`
  );
}

// 0x6963A9813743e786292aEf40dc3b76f83FBf6F4A

// https://mumbai.polygonscan.com/address/0x6963A9813743e786292aEf40dc3b76f83FBf6F4A#code

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});