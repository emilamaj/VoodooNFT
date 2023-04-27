import React, { useState, useEffect } from 'react';
import { getCommitEvents } from './utils/contractInteraction';

function CommitList({ contracts }) {
  const [commitEvents, setCommitEvents] = useState([]);

  useEffect(() => {
    loadCommitEvents();
  }, [contracts]);

  const loadCommitEvents = async () => {
    console.log("loadCommitEvents")
    const events = await getCommitEvents(contracts);
    console.log("Found Commit Events: ", events);
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
              Address: {event.returnValues.user}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}

export default CommitList;