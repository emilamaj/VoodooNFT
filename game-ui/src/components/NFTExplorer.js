import React, { useState, useEffect } from 'react';
import { getMaxID } from './utils/contractInteraction';
import NFTView from './NFTView';

function NFTExplorer( { contracts } ) {
  const [maxId, setMaxId] = useState(null);
  const [idList, setIdList] = useState([]);

  useEffect(() => {
    const fetchMaxId = async () => {
      try {
        const mi = await getMaxID(contracts);
        // Create array of values up to max id
        let il;
        for (il = []; il.push(il.length) < mi;);
        console.log("Found Max ID: ", mi);
        console.log("Found ID List: ", il);
        setMaxId(mi);
        setIdList(il);
      } catch (error) {
        console.error('Error fetching maxId:', error);
      }
    };
    fetchMaxId();
  }, [contracts]);

  

  return (
    <div className="NFTExplorer">
      <h2>NFT Explorer</h2>
      <div className="nft-list">
        {/* {Loop through all NFTs} */}
        {maxId && idList.map((tid) => (
          <NFTView key={tid} tokenId={tid} />
        ))}
      </div>
    </div>
  );
}

export default NFTExplorer;
