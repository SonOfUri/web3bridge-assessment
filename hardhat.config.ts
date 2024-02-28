import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv"
dotenv.config();
const RPC_URL: any = process.env.RPC_URL;
const PRIVATE_KEY: any = process.env.PRIVATE_KEY;
const MUMBAI_API_KEY: any = process.env.MUMBAI_API_KEY;
const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    mumbai: {
      url: `${process.env.ALCHEMY_MUMBAI_URL}`,
      accounts: [`0x${process.env.MUMBAI_PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: MUMBAI_API_KEY,
  },
};

export default config;