import Web3 from 'web3';

const web3 = new Web3(Web3.givenProvider || 'http://localhost:8545');


export async function getContracts() {
  
  // Use fetch() to load the ABIs
  const mintContractOut = await fetch('/ABI/GameMint.json').then((res) => res.json());
  const nftContractOut = await fetch('/ABI/GameNFT.json').then((res) => res.json());
  const params = await fetch('/params.json').then((res) => res.json());
  
  const mintContractAbi = mintContractOut.abi;
  const nftContractAbi = nftContractOut.abi;
  const mintContractAddress = params.mintContractAddress;
  const nftContractAddress = params.nftContractAddress;

  console.log("Mint contract address: ", mintContractAddress);
  console.log("Mint contract ABI: ", mintContractAbi);
  console.log("NFT contract address: ", nftContractAddress);
  console.log("NFT contract ABI: ", nftContractAbi);
  const mintContract = new web3.eth.Contract(mintContractAbi, mintContractAddress);
  const nftContract = new web3.eth.Contract(nftContractAbi, nftContractAddress);
  return {
    mintContract,
    nftContract,
  };
}

// This function is called when the user wants to commit to the game. He needs to pay the price of the NFT.
export async function commit(account, contracts) {
  if (!account) throw new Error('No account provided');

  const txObject = contracts.mintContract.methods.userCommit();

  // The user must pay to commit, the uint256 nftPrice is a public variable in the smart contract
  const price = await contracts.mintContract.methods.nftPrice().call();
  const gas = await txObject.estimateGas({ from: account, value: price });
  const tx = await txObject.send({ from: account, gas });

  return tx;
}

// This function is called when the user wants to mint the NFT
export async function mint(account, contracts) {
  if (!account) throw new Error('No account provided');

  const txObject = contracts.mintContract.methods.userMint();
  const gas = await txObject.estimateGas({ from: account });
  const tx = await txObject.send({ from: account, gas });
  return tx;
}

export async function getCommitEvents(contracts) {
  // Replace with the relevant event name and filter options
  const events = await contracts.mintContract.getPastEvents('UserCommit', {
    fromBlock: 0,
    toBlock: 'latest',
  });
  return events;
}

// Function to return the max ID of the NFTs, stored in the mint contract
export async function getMaxID(contracts) {
  const maxID = await contracts.mintContract.methods.id_count().call();
  return maxID;
}

// Function to return the list of token IDs owned by the given address
export async function getOwnedTokenIds(address, contracts) {
  if (!address) return [];
  if (!contracts) return [];
  // We use contract method "balanceOfBatch(address[] accounts, uint256[] ids)=>(uint256[] balances)"
  const maxID = await getMaxID(contracts);
  const ids = Array.from(Array(maxID).keys());
  const balances = await contracts.nftContract.methods.balanceOfBatch([address], ids).call()
  const tokenIdsOwned = [];
  for (let i = 0; i < balances.length; i++) {
    if (balances[i] > 0) {
      tokenIdsOwned.push(ids[i]);
    }
  }
  return tokenIdsOwned;
}

// Reads the state of the Mint contract. Can be [NOT_DEPLOYED, SETUP, COMMIT, REVEAL, MINT]
export async function getMintContractState(contracts) {
  if (!contracts) return 'NOT_DEPLOYED';
  
  // In params.json, check if isDeployed is true
  const isDeployed = await fetch('/params.json').then((res) => res.json()).then((res) => res.deployed);
  if (!isDeployed) return 'NOT_DEPLOYED';

  const isSetup = await contracts.mintContract.methods.isSetup().call();
  if (!isSetup) return 'SETUP';

  const revealBlock = await contracts.mintContract.methods.revealBlock().call();
  const currentBlock = await web3.eth.getBlockNumber();
  if (currentBlock < revealBlock) return 'COMMIT';

  // Check if the secret has been revealed
  const secret = await contracts.mintContract.methods.adminSecret().call();
  if (secret == 0) return 'REVEAL'; 

  
  // We must be in the MINT phase
  return 'MINT';
}