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
        const UsdtToken = await ethers.getContractFactory("MocUSDT");
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

    it("stake tokens", async function () {
        await qnvToken.connect(owner).updateAdmin(treasuryContract.address);
        expect(await qnvToken.admin()).to.be.equal(treasuryContract.address);

        //send some Moc USDT to user for test
        await usdtToken.connect(owner).transfer(user.address, ethers.utils.parseEther("100"));

        //approve usdt to the treasury contract.
        await usdtToken.connect(user).approve(treasuryContract.address, ethers.utils.parseEther("10"));
        expect(await usdtToken.allowance(user.address, treasuryContract.address)).to.be.equal(ethers.utils.parseEther("10"));

        const allowedAmount = await usdtToken.allowance(user.address, treasuryContract.address);
        console.log("allowed balance : ", allowedAmount);

        await treasuryContract.connect(user).stakeToken(allowedAmount, 1);
        
        //check expired time
        await treasuryContract.connect(user).getTokenExpiry();

        //check user's balance of QNV token
        // expect(await qnvToken.balanceOf(user.address)).to.be.equal(allowedAmount * 5 / 100);
        // test claim before end time.
        // await treasuryContract.connect(user).claimReward();

        
    })

});