const hre = require("hardhat");
const toEther = n => hre.ethers.parseEther(n.toString() , "ether")

async function main() {
  const RacksToken = hre.ethers.getContractFactory("RacksToken")
  const MrCrypto = hre.ethers.getContractFactory("MrCryptoMock")

  // Deploy NFT
  console.log("Deploying MrCrypto...")
  const nft = await MrCrypto.deploy()

  // Deploy token
  const totalSupply = toEther(7000000)
  const minteableSupply = toEther(100000)
  console.log("Deploying Racks Token...")
  const token = await RacksToken.deploy(
    "Racks",
    "RCKS",
    totalSupply,
    minteableSupply,
    minteableSupply/2,
    nft.address
  )
  // mint some mock nfts
  const [deployer , a1, a2, a3] = await hre.ethers.getSigners()
  for(let i=0; i<=16;i++){
    let receiver = i <=4? deployer.address: 4<i<=8 ? a1.address: 8<i<=12? a2.address : a3.address
    console.log(`Minting MrCrypto #${i} to ${receiver}`)
    await nft.mint(receiver, i)
    if(i==4 || i==8 ||i==12 || i==16) await nft.setApprovalForAll(token.address , true)
  }

  

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
