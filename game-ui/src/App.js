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

  useEffect(() => {
    loadContracts();
    const interval = setInterval(() => {
      loadContracts();
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const loadWeb3AndAccount = async () => {
    await loadWeb3();
    const account = await getCurrentAccount();
    setCurrentAccount(account);
  };

  const loadContracts = async () => {
    const isDeployed = await fetch('/params.json').then((res) => res.json()).then((res) => res.deployed);
    if (isDeployed) {
      const ctr = await getContracts();
      if (ctr) {
        setContracts(ctr);
        updateGameState();
      }
    } else {
      setGameState('NOT_DEPLOYED');
    }
  };

  const updateGameState = () => {
    // Fetch game state from contract and update it
    getMintContractState(contracts).then((sta) => {
      setGameState(sta);
    });
  };

  const handleCommit = async () => {
    await loadWeb3AndAccount();
    await commit(currentAccount, contracts);
    updateGameState();
  };

  const handleMint = async () => {
    await loadWeb3AndAccount();
    await mint(currentAccount, contracts);
    updateGameState();
  };

  const renderPhaseContent = () => {
    switch (gameState) {
      case 'NOT_DEPLOYED':
        return <p>Contracts not deployed. Set contract addresses in params.json.</p>;
      case 'SETUP':
        return <p>Admin should set the reveal block, commit price, and secret hash.</p>;
      case 'COMMIT':
        return (
          <>
            <CommitUser handleCommit={handleCommit} />
            <CommitList />
          </>
        );
      case 'REVEAL':
        return <p>Waiting for admin to reveal the secret.</p>;
      case 'MINT':
        return <MintUser handleMint={handleMint} />;
      default:
        return <p>Loading...</p>;
    }
  };

  return (
    <div className="App">
      <h1>My NFT Project</h1>
      {renderPhaseContent()}
      <NFTExplorer />
      <NFTList address={currentAccount} contracts={contracts} />
      {/* Render NFTView only if a specific NFT is selected */}
      {/*<NFTView tokenId={tokenId} />*/}
    </div>
  );
}

export default App;