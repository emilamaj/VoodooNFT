import React, { useState, useEffect } from 'react';
import { loadWeb3, getCurrentAccount } from './components/utils/web3Provider';
import { getContracts, commit, mint, getMintContractState } from './components/utils/contractInteraction';
import CommitList from './components/CommitList';
import MintList from './components/MintList';
import CommitUser from './components/CommitUser';
import MintUser from './components/MintUser';
import NFTExplorer from './components/NFTExplorer';
import NFTList from './components/NFTList';
import NFTView from './components/NFTView';
import ErrorDisplay from './components/ErrorDisplay';
// Load css files
import './App.css';

function App() {
  const [contracts, setContracts] = useState(null);
  const [gameState, setGameState] = useState('NOT_DEPLOYED');
  const [currentAccount, setCurrentAccount] = useState(null);
  const [committedNFTs, setCommittedNFTs] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadContracts();
    const interval = setInterval(() => {
      console.log("refresh interval")
      loadContracts();
    }, 30000);
    return () => clearInterval(interval);
  }, []);

  const getAccountFromWallet = async () => {
    let acc = currentAccount;
    if (!acc) {
      console.log("loadWeb3AndAccount")
      await loadWeb3();
      const account = await getCurrentAccount();
      setCurrentAccount(account);
      acc = account;
    }
    return acc
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
    setLoading(true);
    try {
      let acc = await getAccountFromWallet();
      await commit(acc, contracts);
      loadContracts();
      updateGameState();
    } catch (error) {
      console.error(`Error during commit: ${error.message}`);
      setError(error);
    } finally {
      setLoading(false);
    }
  };

  const handleMint = async () => {
    console.log("handleMint");
    setLoading(true);
    try {
      let acc = await getAccountFromWallet();
      console.log("Using account: " + acc);
      await mint(acc, contracts);
      loadContracts();
      updateGameState();
    } catch (error) {
      console.error(`Error during mint: ${error.message}`);
      setError(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (contracts) {
      console.log("contract change hook")
      updateGameState();
    }
  }, [contracts]);

  const renderPhaseContent = () => {
    return (
      <>
        <h2>Game State</h2>
        {gameState === 'NOT_DEPLOYED' && <p>Waiting for deployment. Set contract addresses in params.json</p>}
        {gameState === 'SETUP' && <p>Waiting for admin to setup the reveal block height, commit price, and secret hash.</p>}
        {gameState === 'COMMIT' && <CommitUser handleCommit={handleCommit} />}
        {gameState === 'REVEAL' && <p>Reveal block reached. Waiting for admin to reveal the secret.</p>}
        {gameState === 'MINT' && <MintUser handleMint={handleMint} />}
      </>
    );
  };

  return (
    <div className="App">
      <h1>Harry Potter NFTs</h1>
      <p>Simple NFT project showcasing a commit-reveal sale mechanism.</p>
      <div className="game-state">
        <div className='game-state-core'>
          {renderPhaseContent()}
          {loading && <div className="loading-spinner">Loading...</div>}
          <ErrorDisplay error={error} />
        </div>
        <div className="game-state-event-viewer">
          <CommitList contracts={contracts} />
          <MintList contracts={contracts} />
        </div>
      </div>
      <div className="game-misc">
        <NFTList address={currentAccount} contracts={contracts} connectWalletCallback={getAccountFromWallet} />
        <NFTExplorer contracts={contracts} />
      </div>
    </div>
  );
}

export default App;