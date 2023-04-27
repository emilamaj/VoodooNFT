import React, { useState, useEffect } from 'react';
import { getMintEvents } from './utils/contractInteraction';

function MintList({ contracts }) {
  const [mintEvents, setMintEvents] = useState([]);

  useEffect(() => {
    loadMintEvents();
  }, [contracts]);

  const loadMintEvents = async () => {
    console.log("loadMintEvents")
    const events = await getMintEvents(contracts);
    console.log("Found Mint Events: ", events);
    setMintEvents(events);
  };

  return (
    <div className="MintList">
      <h2>Last Mints</h2>
      {mintEvents.length === 0 ? (
        <p>No mints yet.</p>
      ) : (
        <ul>
          {mintEvents.map((event, index) => (
            <li key={index}>
              Address: {event.returnValues.user}, NFT ID: {event.returnValues.nftId}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default MintList;