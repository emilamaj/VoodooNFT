import React, { useState, useEffect } from 'react';
import { getCommitEvents } from './utils/contractInteraction';

function CommitList() {
  const [commitEvents, setCommitEvents] = useState([]);

  useEffect(() => {
    loadCommitEvents();
  }, []);

  const loadCommitEvents = async () => {
    const events = await getCommitEvents();
    setCommitEvents(events);
  };

  return (
    <div className="CommitList">
      <h2>Last Commitments</h2>
      {commitEvents.length === 0 ? (
        <p>No commitments yet.</p>
      ) : (
        <ul>
          {commitEvents.map((event, index) => (
            <li key={index}>
              Address: {event.returnValues.user}, Token Id: {event.returnValues.tokenId}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default CommitList;