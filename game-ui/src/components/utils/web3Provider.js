import Web3 from 'web3';

const rpcUrl = readRpcUrl();
let web3 = new Web3(Web3.givenProvider || rpcUrl);

async function readRpcUrl() {
  return await fetch('/params.json').then((res) => res.json()).then((res) => res.rpcUrl);
}

export async function loadWeb3() {
  if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    try {
      await window.ethereum.enable();
      return web3;
    } catch (error) {
      alert('User denied account access');
      throw new Error('User denied account access');
    }
  } else if (window.web3) {
    web3 = new Web3(window.web3.currentProvider);
  } else {
    alert('Please install MetaMask');
    throw new Error('No MetaMask detected');
  }
}

export async function getCurrentAccount() {
  if (!web3) throw new Error('Web3 is not initialized');

  const accounts = await web3.eth.getAccounts();
  if (!accounts || accounts.length === 0) {
    alert('No account found');
    throw new Error('No account found');
  }

  return accounts[0];
}