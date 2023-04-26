import React, { useState, useEffect } from 'react';
import NFTView from './NFTView';
import { getOwnedTokenIds } from './utils/contractInteraction';

function NFTList({ address }) {
  const [ownedTokenIds, setOwnedTokenIds] = useState([]);
  const [selectedTokenId, setSelectedTokenId] = useState(null);

  useEffect(() => {
    fetchOwnedTokenIds(address);
  }, [address]);

  const fetchOwnedTokenIds = async (address) => {
    // Fetch token ids owned by the given address
    const tokenIdsOwned = await getOwnedTokenIds(address);
    setOwnedTokenIds(tokenIdsOwned);
  };

  const handleTokenIdClick = (tokenId) => {
    setSelectedTokenId(tokenId);
  };

  return (
    <div className="NFTList">
      <h2>NFT List</h2>
      {address && (
        <p>Displaying NFTs owned by {address}</p>
      )}
      <div className="token-list">
        {ownedTokenIds.map((tokenId, index) => (
          <button key={index} onClick={() => handleTokenIdClick(tokenId)}>
            Token {tokenId}
          </button>
        ))}
      </div>
      {selectedTokenId !== null && <NFTView tokenId={selectedTokenId} />}
    </div>
  );
}

export default NFTList;