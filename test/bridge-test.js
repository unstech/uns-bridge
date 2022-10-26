const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UnsTokenBridge", function () {
  it("Should check the fulfillments once it's deployed", async function () {
    const [signer] = await ethers.getSigners();

    const UnsTokenBridge = await hre.ethers.getContractFactory("UnsTokenBridge");
    const unsTokenBridge = await UnsTokenBridge.deploy();
    await unsTokenBridge.deployed();

    const fulfillmentId = 1;
    const amountToTransfer = ethers.utils.parseEther("100");
    const totalSupply = ethers.utils.parseEther("100");

    expect(await unsTokenBridge.fulfillments(fulfillmentId)).to.equal(false);

    const TestToken = await hre.ethers.getContractFactory("TestToken");
    const testToken = await TestToken.deploy(totalSupply);
    await testToken.deployed();

    let tx = await testToken.transfer(unsTokenBridge.address, amountToTransfer);
    await tx.wait();
    expect(await testToken.balanceOf(unsTokenBridge.address)).to.equal(amountToTransfer);

    tx = await unsTokenBridge.withdrawToken(testToken.address, amountToTransfer, fulfillmentId);
    await tx.wait();

    expect(await unsTokenBridge.fulfillments(fulfillmentId)).to.equal(true);

  });
});
