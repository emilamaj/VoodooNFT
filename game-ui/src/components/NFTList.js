import React, { useState, useEffect } from 'react';
import NFTView from './NFTView';
import { getOwnedTokenIds } from './utils/contractInteraction';

function NFTList({ address, contracts, connectWalletCallback }) {
  const [ownedTokenIds, setOwnedTokenIds] = useState([]);
  const [selectedTokenId, setSelectedTokenId] = useState(null);

  useEffect(() => {
    fetchOwnedTokenIds(address);
  }, [address, contracts]);

  const fetchOwnedTokenIds = async (address) => {
    // Fetch token ids owned by the given address
    const tokenIdsOwned = await getOwnedTokenIds(address, contracts);
    setOwnedTokenIds(tokenIdsOwned);
  };

  const handleTokenIdClick = (tokenId) => {
    console.log("handleTokenIdClick", tokenId)
    setSelectedTokenId(tokenId);
  };

  return (
    <div className="NFTList">
      <h2>Personnal NFT Portfolio</h2>
      {/* If the addres provided is null, display a button to connect the wallet */}
      {!address && (
        <button onClick={connectWalletCallback}>Connect Wallet</button>
      )}
      {address && (
        <p>NFTs owned by {address} (count: {ownedTokenIds.length})</p>
      )}
      <div className="token-list">
        {ownedTokenIds.map((tokenId, index) => (
          <button key={index} onClick={() => handleTokenIdClick(tokenId)}>
            View id={tokenId}
          </button>
        ))}
      </div>
      {selectedTokenId !== null && <NFTView tokenId={selectedTokenId} />}
    </div>
  );
}

export default NFTList;