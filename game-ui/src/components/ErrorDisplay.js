import React from 'react';

function ErrorDisplay({ error }) {
  if (!error) {
    return null;
  }

  return (
    <div className="ErrorDisplay">
      <p>Error: {error.message}</p>
    </div>
  );
}

export default ErrorDisplay;