import React, { useState, useEffect } from 'react';
import { loadWeb3, getCurrentAccount } from './components/utils/web3Provider';
import { getContracts, commit, mint, getMintContractState } from './components/utils/contractInteraction';
import CommitList from './components/CommitList';
import CommitUser from './components/CommitUser';
import MintUser from './components/MintUser';
import NFTExplorer from './components/NFTExplorer';
import NFTList from './components/NFTList';
import NFTView from './components/NFTView';

function App() {
  const [contracts, setContracts] = useState(null);
  const [gameState, setGameState] = useState('NOT_DEPLOYED');
  const [currentAccount, setCurrentAccount] = useState(null);
  const [committedNFTs, setCommittedNFTs] = useState(null);
  const [commitEventsUpdated, setCommitEventsUpdated] = useState(false);

  useEffect(() => {
    loadContracts();
    const interval = setInterval(() => {
      console.log("refresh interval")
      loadContracts();
    }, 30000);
    return () => clearInterval(interval);
  }, []);

  const loadWeb3AndAccount = async () => {
    console.log("loadWeb3AndAccount")
    await loadWeb3();
    const account = await getCurrentAccount();
    setCurrentAccount(account);
  };

  const loadContracts = async () => {
    console.log("loadContracts")
    const isDeployed = await fetch('/params.json').then((res) => res.json()).then((res) => res.deployed);
    if (isDeployed) {
      const ctr = await getContracts();
      if (ctr) {
        setContracts(ctr);
      }
    } else {
      setGameState('NOT_DEPLOYED');
    }
  };

  const updateGameState = () => {
    console.log("updateGameState")
    // Fetch game state from contract and update it
    getMintContractState(contracts).then((sta) => {
      setGameState(sta);
    });
  };

  // Update the handleCommit function
  const handleCommit = async () => {
    console.log("handleCommit");
    await loadWeb3AndAccount();
    await commit(currentAccount, contracts);
    updateGameState();
    setCommitEventsUpdated(!commitEventsUpdated); // Toggle the state variable to trigger a refresh
  };



  const handleMint = async () => {
    console.log("handleMint");
    if (!currentAccount) {
      await loadWeb3AndAccount();
    }
    await mint(currentAccount, contracts);
    updateGameState();
  };
  

  useEffect(() => {
    if (contracts) {
      console.log("contract change hook")
      updateGameState();
    }
  }, [contracts]);

  const renderPhaseContent = () => {
    switch (gameState) {
      case 'NOT_DEPLOYED':
        return <p>Wainting for deployment. Set contract addresses in params.json</p>;
      case 'SETUP':
        return <p>Waiting for admin to setup the reveal block height, commit price, and secret hash.</p>;
      case 'COMMIT':
        return (
          <>
            <CommitUser handleCommit={handleCommit} />
          </>
        );
      case 'REVEAL':
        return <p>Reveal block reached. Waiting for admin to reveal the secret.</p>;
      case 'MINT':
        return <MintUser handleMint={handleMint} />;
      default:
        return <p>Loading...</p>;
    }
  };

  return (
    <div className="App">
      <h1>Harry Potter NFTs</h1>
      {renderPhaseContent()}
      <CommitList contracts={contracts} commitEventsUpdated={commitEventsUpdated} />
      <NFTExplorer />
      <NFTList address={currentAccount} contracts={contracts} />
      {/* Render NFTView only if a specific NFT is selected */}
      {/*<NFTView tokenId={tokenId} />*/}
    </div>
  );
}

export default App;