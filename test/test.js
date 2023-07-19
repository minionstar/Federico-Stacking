const { expect } = require("chai");
const { ethers } = require("hardhat");
require("hardhat-gas-reporter");


describe("test QNV token", function () {
    let accounts;
    let qnvToken;
    let usdtToken;
    let treasury;
    let owner;
    let user;

    before(async function () {
        accounts = await ethers.getSigners();
        owner = accounts[0];
        user = accounts[1];
    })

    beforeEach(async function () {

        //deploy qnv token
        const QnvToken = await ethers.getContractFactory("QNVToken");
        qnvToken = await QnvToken.deploy();
        await qnvToken.deployed();
        console.log("QNV token successfully deployed to ", qnvToken.address);

        //deploy moc usdt token
        const UsdtToken = await ethers.getContractFactory("QNVToken");
        usdtToken = await UsdtToken.deploy();
        await usdtToken.deployed();
        console.log("Moc USDT token successfully deployed to ", usdtToken.address);

        //deploy treasury contract
        const TreasuryContract = await ethers.getContractFactory("StakeQNV");
        treasuryContract = await TreasuryContract.deploy(qnvToken.address, usdtToken.address);
        console.log("treasury contract was successfully deployed to ", treasuryContract.address);
    })

    it("set the treasury as an admin", async function () {
        await qnvToken.connect(owner).updateAdmin(owner.address);
        expect(await qnvToken.admin()).to.be.equal(owner.address);
    })

});