require("@nomiclabs/hardhat-waffle");

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
  defaultNetwork: "hardhat",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {},
    ropsten: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/JIGtGieoV-DRZMJZtE3GiKKUlB7JIL6v",
      accounts: [`0x95fda7eeab8021f0a3f897588e37afb04382b08a8119e9c33bf40b631f2e220c`]
                    
    }
  },
  solidity: "0.8.0",
  gasReporter: {
    currency: 'CHF',
    gasPrice: 21
  }
};
