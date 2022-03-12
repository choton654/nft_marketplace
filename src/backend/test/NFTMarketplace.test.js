/* eslint-disable jest/valid-expect */
const { expect } = require("chai");
const { ethers } = require("ethers");

describe("NFTMarketPlace", () => {
  beforeEach(async () => {
    let deployer, addr1, addr2, nft, marketPlace;
    let feeParcent = 1;
    let URI = "Sample URI";

    const NFT = await ethers.getContractFactory("NFT");
    const MarketPlace = await ethers.getContractFactory("Marketplace");

    [deployer, addr1, addr2] = await ethers.getSigners();

    nft = await NFT.deploy();
    marketPlace = await MarketPlace.deploy(1);

    describe("Deployment", () => {
      it("Should track name and symbol of the nft collection", async () => {
        expect(await nft.name()).to.equal("DApp NFT");
        expect(await nft.symbol()).to.equal("DAPP");
      });
      it("Should track feeAccount and feeParent of the marketplace", async () => {
        expect(await marketPlace.feeAccount()).to.equal(deployer.address);
        expect(await marketPlace.feeParent()).to.equal(feeParcent);
      });
    });

    describe("Minting NFTs", () => {
      it("Should track each mint NFT", async () => {
        await nft.connect(addr1).mint(URI);
        expect(await nft.tokenCount()).to.equal(1);
        expect(await nft.balanceOf(addr1.address)).to.equal(1);
        expect(await nft.tokenURI(1)).to.equal(URI);

        await nft.connect(addr2).mint(URI);
        expect(await nft.tokenCount()).to.equal(2);
        expect(await nft.balanceOf(addr1.address)).to.equal(1);
        expect(await nft.tokenURI(2)).to.equal(URI);
      });
    });
  });
});
