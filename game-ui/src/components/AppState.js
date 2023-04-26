import { useState, useEffect } from 'react';
import { getGameState, getContractAddresses } from './utils/contractInteraction';

const AppState = ({ children }) => {
  const [gameState, setGameState] = useState(null);
  const [contractAddresses, setContractAddresses] = useState(null);

  useEffect(() => {
    const fetchState = async () => {
      try {
        const addresses = await getContractAddresses();
        setContractAddresses(addresses);

        const state = await getGameState(addresses);
        setGameState(state);
      } catch (error) {
        console.error('Error fetching game state:', error);
      }
    };

    fetchState();
  }, []);

  if (!gameState || !contractAddresses) {
    return <div>Loading game state...</div>;
  }

  return (
    <div>
      {children({ gameState, contractAddresses })}
    </div>
  );
};

export default AppState;