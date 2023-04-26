import React, { useState, useEffect } from 'react';
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
  }, []);

  const loadContracts = async () => {
    const contracts = await getContracts();
    if (contracts) {
      setContracts(contracts);
      updateGameState();
    }
  };

  const updateGameState = () => {
    // Fetch game state from contract and update it
    getMintContractState().then((sta) => {
      setGameState(sta);
    });
  };

  const handleCommit = async () => {
    await commit(currentAccount);
    updateGameState();
  };

  const handleMint = async () => {
    await mint(currentAccount);
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
      <NFTList address={currentAccount} />
      {/* Render NFTView only if a specific NFT is selected */}
      {/*<NFTView tokenId={tokenId} />*/}
    </div>
  );
}

export default App;