// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// Import some OpenZeppelin Contracts
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// Import the helper functions from the contract
import { Base64 } from "./libraries/Base64.sol";

 // Inherit the imported contract.
contract MijoNFT is ERC721URIStorage {
    // OpenZeppelin magic to keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Base SVG code that all NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // Random words, each with their own theme.
    string[] firstWords = ["Milic", "Patojo", "Cerote", "Viejo", "Chavo", "Wiro", "Jefe", "Cuate", "Colocho", "Canche", "Tigre", "Cuate"];
    string[] secondWords = ["Chispudo", "Guapo", "Sheca", "Baboso", "Mula", "Cerote", "Trompudo", "Yuca", "Pistudo", "Bracas", "Deahuevo", "Shute", "Culebra"];
    string[] thirdWords = ["Bolo", "Caquero", "Casaquero", "Clavero", "Chambeador", "Gallo", "Pajero", "Borracho", "Tikinay", "Basura", "Shuco", "Gato", "Parrandero"];

    event NewMijoNFTMinted(address sender, uint256 tokenId);

    // Need to pass the name of the NFT token and its symbol.
    constructor() ERC721 ("MijoNFT", "MIJO") {
        console.log("Mijo NFT contract. LFG!");
    }

    // Randomly pick a word for each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // Seed the random generator.
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));

        // Squash the # between 0 and n to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT
    function makeMijoNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // Randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // Concatenate and close <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // Set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A collection of chapinismos.", "image": "data:image/svg+xml;base64,',
                        // Add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Prepend data:application/json;base64, to data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);


        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        emit NewMijoNFTMinted(msg.sender, newItemId);
     }
 }