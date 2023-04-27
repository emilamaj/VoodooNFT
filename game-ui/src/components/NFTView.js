import React, { useState, useEffect } from 'react';

function NFTView({ tokenId }) {
  const [metadata, setMetadata] = useState(null);

  useEffect(() => {
    fetchMetadata(tokenId);
  }, [tokenId]);

  const fetchMetadata = async (tokenId) => {
    console.log("fetchMetadata", tokenId)
    try {
      const response = await fetch(`/metadata/${tokenId}.json`);
      const metadata = await response.json();
      console.log("metadata", metadata)
      setMetadata(metadata);
    } catch (e) {
      console.error("Error when fetching metadata", e)
    }
  };

  if (!metadata) {
    return <div>Loading metadata...</div>;
  }

  return (
    <div className="NFTView">
      <h3>Token ID: {tokenId}</h3>
      <img src={`/metadata/${tokenId}.png`} alt={metadata.name} style={{ width: '100px' }} />
      {/* If the image is too big, you can resize it with CSS:*/}

      {metadata && <div className="div-nft-metadata">
          <p>{metadata.name}</p>
          <p>{metadata.description}</p>
      </div>}
    </div>
  );
}

export default NFTView;