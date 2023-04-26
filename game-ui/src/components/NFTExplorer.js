import React, { useState, useEffect } from 'react';
import NFTView from './NFTView';

function NFTExplorer() {
  const [tokenIds, setTokenIds] = useState([]);
  const [selectedTokenId, setSelectedTokenId] = useState(null);

  const handleTokenIdClick = (tokenId) => {
    setSelectedTokenId(tokenId);
  };

  return (
    <div className="NFTExplorer">
      <h2>NFT Explorer</h2>
      <div className="token-list">
        {tokenIds.map((tokenId, index) => (
          <button key={index} onClick={() => handleTokenIdClick(tokenId)}>
            Token {tokenId}
          </button>
        ))}
      </div>
      {selectedTokenId !== null && <NFTView tokenId={selectedTokenId} />}
    </div>
  );
}

export default NFTExplorer;
