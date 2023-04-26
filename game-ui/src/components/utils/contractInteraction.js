import Web3 from 'web3';
import mintContractAbi from '/ABI/GameMint.json';
import nftContractAbi from '/ABI/GameNFT.json';

const web3 = new Web3(Web3.givenProvider || 'http://localhost:8545');


// const contractAddress = '0xYourContractAddress';
// Instead of hardcoding the contract address, we can get it from /params.json
const mintContractAddress = require('/params.json').mintContractAddress;
const nftContractAddress = require('/params.json').nftContractAddress;


export async function getContracts() {
  const mintContract = new web3.eth.Contract(mintContractAbi, mintContractAddress);
  const nftContract = new web3.eth.Contract(nftContractAbi, nftContractAddress);
  return {
    mintContract,
    nftContract,
  };
}

// This function is called when the user wants to commit to the game. He needs to pay the price of the NFT.
export async function commit(account) {
  if (!account) throw new Error('No account provided');

  const txObject = mintContract.methods.userCommit();

  // The user must pay to commit, the uint256 nftPrice is a public variable in the smart contract
  const price = await mintContract.methods.nftPrice().call();
  const gas = await txObject.estimateGas({ from: account, value: price });
  const tx = await txObject.send({ from: account, gas });

  return tx;
}

// This function is called when the user wants to mint the NFT
export async function mint(account) {
  if (!account) throw new Error('No account provided');

  const txObject = mintContract.methods.userMint();
  const gas = await txObject.estimateGas({ from: account });
  const tx = await txObject.send({ from: account, gas });
  return tx;
}

export async function getCommitEvents() {
  // Replace with the relevant event name and filter options
  const events = await mintContract.getPastEvents('UserCommit', {
    fromBlock: 0,
    toBlock: 'latest',
  });
  return events;
}

// Function to return the max ID of the NFTs, stored in the mint contract
export async function getMaxID() {
  const maxID = await mintContract.methods.ID_COUNT().call();
  return maxID;
}

// Function to return the list of token IDs owned by the given address
export async function getOwnedTokenIds(address) {
  // We use contract method "balanceOfBatch(address[] accounts, uint256[] ids)=>(uint256[] balances)"
  const maxID = await getMaxID();
  const ids = Array.from(Array(maxID).keys());
  const balances = await nftContract.methods.balanceOfBatch([address], ids).call()
  const tokenIdsOwned = [];
  for (let i = 0; i < balances.length; i++) {
    if (balances[i] > 0) {
      tokenIdsOwned.push(ids[i]);
    }
  }
  return tokenIdsOwned;
}

// Reads the state of the Mint contract. Can be [NOT_DEPLOYED, SETUP, COMMIT, REVEAL, MINT]
export async function getMintContractState() {
  // In params.json, check if isDeployed is true
  const isDeployed = require('/params.json').isDeployed;
  if (!isDeployed) return 'NOT_DEPLOYED';

  const isSetup = await mintContract.methods.isSetup().call();
  if (!isSetup) return 'SETUP';

  const revealBlock = await mintContract.methods.revealBlock().call();
  const currentBlock = await web3.eth.getBlockNumber();
  if (currentBlock < revealBlock) return 'COMMIT';

  // Check if the secret has been revealed
  const secret = await mintContract.methods.adminSecret().call();
  if (secret == 0) return 'REVEAL';

  // We must be in the MINT phase
  return 'MINT';
}
