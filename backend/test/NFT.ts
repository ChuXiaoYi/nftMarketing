import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("NFT", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    return { nft, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should deploy success", async function () {
      const { nft, owner, otherAccount } = await loadFixture(
        deployOneYearLockFixture
      );
      expect(await nft.owner()).to.equal(owner.address);
    });
  });
});
