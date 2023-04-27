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
      <h3 className='NFTView-title'>Token ID: {tokenId}</h3>
      <div className='NFTView-content'>
        <img src={`/metadata/${tokenId}.png`} alt={metadata.name}/>
        {metadata && <div className="div-nft-metadata">
          <p className='metadata-name'>{metadata.name}</p>
          <p className='metadata-description'>{metadata.description}</p>
        </div>}
      </div>
    </div>
  );
}

export default NFTView;