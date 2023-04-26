import React, { useState, useEffect } from 'react';

function NFTView({ tokenId }) {
  const [metadata, setMetadata] = useState(null);

  useEffect(() => {
    fetchMetadata(tokenId);
  }, [tokenId]);

  const fetchMetadata = async (tokenId) => {
    const response = await fetch(`/metadata/${tokenId}.json`);
    const metadata = await response.json();
    setMetadata(metadata);
  };

  if (!metadata) {
    return <div>Loading metadata...</div>;
  }

  return (
    <div className="NFTView">
      <h3>Token ID: {tokenId}</h3>
      <img src={`/metadata/${tokenId}.png`} alt={metadata.name} />
      <ul>
        {Object.entries(metadata).map(([key, value]) => (
          <li key={key}>
            {key}: {value}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default NFTView;