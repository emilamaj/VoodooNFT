import React from 'react';

function CommitUser({ handleCommit }) {
  return (
    <div className="CommitUser">
      <h2>Commit to Mint</h2>
      <p>Pay the set price to commit to a mint before the reveal block is reached.</p>
      <button onClick={handleCommit}>Commit</button>
    </div>
  );
}

export default CommitUser;