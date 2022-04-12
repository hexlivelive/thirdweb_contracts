// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.11;

contract ThirdwebContract {
    /// @dev The publish metadata of the contract of which this contract is an instance.
    string private publishMetadataUri;
    /// @dev The metadata for this contract.
    string public contractURI;

    struct ThirdwebInfo {
        string publishMetadataUri;
        string contractURI;
    }

    /// @dev Returns the publish metadata for this contract.
    function getPublishMetadataUri() external view returns (string memory) {
        return publishMetadataUri;
    }

    /// @dev Initializes the publish metadata and contract metadata at deploy time.
    function setThirdwebInfo(ThirdwebInfo memory _thirdwebInfo) external {
        require(bytes(publishMetadataUri).length == 0, "Already initialized");

        publishMetadataUri = _thirdwebInfo.publishMetadataUri;
        contractURI = _thirdwebInfo.contractURI;
    }
}
