import React from 'react';

function MintUser({ handleMint }) {
  return (
    <div className="MintUser">
      <h3>Mint Your NFT</h3>
      <p>You can now mint the NFT you committed to during the commit phase.</p>
      <button onClick={handleMint}>Mint NFT</button>
    </div>
  );
}

export default MintUser;
