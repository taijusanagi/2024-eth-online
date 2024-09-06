// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./JWT.sol";
import "./RSAPKCS1Verifier.sol";

import "hardhat/console.sol";

contract AuthWallet is JWT, RSAPKCS1Verifier {
    // Hardcoded exponent (common value for RSA public exponent)
    bytes public constant EXPONENT = hex"010001"; // 65537 in hexadecimal

    // Mapping to store modulus for each kid
    mapping(string => bytes) public kidToModulus;

    // Event to log when a new modulus is set
    event ModulusSet(string indexed kid, bytes modulus);

    // Function to set modulus for a specific kid
    function setModulus(string memory _kid, bytes calldata _modulus) public {
        kidToModulus[_kid] = _modulus;
        emit ModulusSet(_kid, _modulus);
    }

    // Function to validate JWT
    function validateJWT(string memory _jwt) public view returns (bool) {
        // Split the JWT
        (
            string memory header,
            string memory payload,
            string memory signature
        ) = split(_jwt);

        // Extract the kid from the header
        string memory kid = extractKid(header);

        // Get the modulus for the kid
        bytes memory modulus = kidToModulus[kid];
        require(modulus.length > 0, "Modulus not found for the given kid");

        // Hash the header and payload
        bytes32 messageHash = hashHeaderAndPayload(header, payload);

        // Decode the signature
        bytes memory decodedSignature = decodeSignature(signature);

        // Verify the signature
        return verify(messageHash, decodedSignature, EXPONENT, modulus);
    }
}
