// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleAttendanceNFT {
    struct NFTMetadata {
        bool isCollateralized;
        uint256 collateralAmount;
        address owner;
    }

    uint256 public totalSupply;
    mapping(uint256 => NFTMetadata) public nftDetails;

    event NFTMinted(address indexed to, uint256 tokenId);
    event NFTCollateralized(uint256 indexed tokenId, uint256 collateralAmount);
    event NFTRedeemed(uint256 indexed tokenId);

    /**
     * @dev Mint an NFT to signify attendance.
     * @param to Address to mint the NFT to.
     */
    function mint(address to) external {
        require(to != address(0), "Invalid address");

        totalSupply++;
        uint256 tokenId = totalSupply;

        nftDetails[tokenId] = NFTMetadata({
            isCollateralized: false,
            collateralAmount: 0,
            owner: to
        });

        emit NFTMinted(to, tokenId);
    }

    /**
     * @dev Collateralize an NFT.
     * @param tokenId The ID of the NFT to be collateralized.
     */
    function collateralize(uint256 tokenId) external payable {
        NFTMetadata storage nft = nftDetails[tokenId];
        require(nft.owner == msg.sender, "You do not own this NFT.");
        require(!nft.isCollateralized, "NFT is already collateralized.");
        require(msg.value > 0, "Collateral amount must be greater than zero.");

        nft.isCollateralized = true;
        nft.collateralAmount = msg.value;

        emit NFTCollateralized(tokenId, msg.value);
    }

    /**
     * @dev Redeem an NFT and retrieve the collateral.
     * @param tokenId The ID of the NFT to be redeemed.
     */
    function redeem(uint256 tokenId) external {
        NFTMetadata storage nft = nftDetails[tokenId];
        require(nft.owner == msg.sender, "You do not own this NFT.");
        require(nft.isCollateralized, "NFT is not collateralized.");

        uint256 collateralAmount = nft.collateralAmount;
        nft.isCollateralized = false;
        nft.collateralAmount = 0;

        (bool success, ) = msg.sender.call{value: collateralAmount}("");
        require(success, "Transfer failed.");

        emit NFTRedeemed(tokenId);
    }

    receive() external payable {}
}
