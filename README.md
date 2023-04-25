# NFT Test Project - Voodoo Blockchain Engineer Test

This project is a simple NFT project. It is articulated in a simple NFT contract accompanied by a sale contract.

## TODO:
- [x] Create a simple NFT contract
- [x] Create a simple sale contract
- [x] Add Event logging:
    - [x] GameNFT
    - [x] GameMint
- [X] Add Role setup
    - [X] GameNFT
        - [X] Admin
        - [x] Minter
    - [x] GameMint
        - [x] Admin
- [X] Add tests:
    - [X] Unit tests:
        - [x] GameNFT
            - [x] Deploy
            - [x] ContractURI
            - [x] TokenURI
            - [x] SupportsInterface	
            - [x] AddAdminRole/RemoveAdminRole
            - [x] AddMinterRole/RemoveMinterRole
            (inherited/optional)
            - [] Mint
            - [] Transfer
        - [X] GameMint
            - [x] Deploy
            - [x] AdminSetup
            - [x] UserCommit
            - [x] Reveal
            - [x] UserMint
            - [X] WithdrawFunds
            - [x] AddAdminRole/RemoveAdminRole

- [] Create a simple frontend to interact with the contracts

## How to run tests
To run tests, run the following command:

Local testing:
```bash
forge test -vv
```

Mainnet fork with personnal Infura key:
```bash
forge test -vv --fork-url <RPC_URL>
```

## How to deploy

To deploy the contracts, run the following command:
