// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct PlayerData {
        uint256 playerid;
        uint256 level;
        uint256 hp;
        uint256 strength;
        uint256 speed;
    }

    mapping(uint256 => PlayerData) public tokenIdToPlayerData;

    // Initializing the state variable
    uint256 randNonce = 0;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            "<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>Id: ",
            getId(tokenId),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            getLevels(tokenId),
            "</text>",
            "<text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>HP: ",
            getHP(tokenId),
            "</text>",
            "<text x='50%' y='70%' class='base' dominant-baseline='middle' text-anchor='middle'>Strength: ",
            getStrength(tokenId),
            " pascal</text>",
            "<text x='50%' y='80%' class='base' dominant-baseline='middle' text-anchor='middle'>Speed: ",
            getSpeed(tokenId),
            " km/h</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getId(uint256 tokenId) public view returns (string memory) {
        PlayerData memory IDs = tokenIdToPlayerData[tokenId];
        return IDs.playerid.toString();
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        PlayerData memory levels = tokenIdToPlayerData[tokenId];
        return levels.level.toString();
    }

    function getHP(uint256 tokenId) public view returns (string memory) {
        PlayerData memory playerHP = tokenIdToPlayerData[tokenId];
        return playerHP.hp.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        PlayerData memory playerStrength = tokenIdToPlayerData[tokenId];
        return playerStrength.strength.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        PlayerData memory playerSpeed = tokenIdToPlayerData[tokenId];
        return playerSpeed.speed.toString();
    }

    function createRandom() internal returns (uint256) {
        // increase nonce
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % 100;
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        // creating random speed, strength, life --- keeping initial level = 1 (incrementing by 1 from here), and id constant
        PlayerData memory playerData = PlayerData(
            newItemId,
            1,
            createRandom(),
            createRandom(),
            createRandom()
        );
        tokenIdToPlayerData[newItemId] = playerData;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing Token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );
        PlayerData memory currentPlayerData = tokenIdToPlayerData[tokenId];
        PlayerData memory updatePlayerData;
        updatePlayerData = PlayerData(
            currentPlayerData.playerid,
            currentPlayerData.level + 1,
            currentPlayerData.hp + 5,
            currentPlayerData.strength + 10,
            currentPlayerData.speed + 25
        );
        tokenIdToPlayerData[tokenId] = updatePlayerData;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
