// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";

import "./PackControl.sol";
import "./interfaces/RNGInterface.sol";

contract PackERC1155 is ERC1155PresetMinterPauser {

  PackControl internal controlCenter;
  string public constant PACK_HANDLER_MODULE_NAME = "PACK_HANDLER";

  uint public currentTokenId;

  struct Token {
    address creator;
    string uri;
    uint circulatingSupply;
  }

  /// @dev tokenId => Token state.
  mapping(uint => Token) public tokens;

  modifier onlyHandler() {
    require(msg.sender == controlCenter.getModule(PACK_HANDLER_MODULE_NAME), "Only the protocol pack token handler can call this function.");
    _;
  }

  constructor(address _controlCenter) ERC1155PresetMinterPauser("") {
    controlCenter = PackControl(_controlCenter);
    grantRole(DEFAULT_ADMIN_ROLE, _controlCenter);
    grantRole(PAUSER_ROLE, _controlCenter);
  }

  /// @dev Called by the pack handler to mint new tokens.
  function mintToken(
    address _creator,
    uint _id,
    uint _amount,
    string calldata _uri
  ) external onlyHandler {

    // Update token state in mapping.

    if(tokens[_id].creator != address(0)) {
      tokens[_id].circulatingSupply += _amount;
    } else {
      tokens[_id] = Token({
        creator: _creator,
        uri: _uri,
        circulatingSupply: _amount
      });
    }

    // Mint tokens to pack creator.
    mint(_creator, _id, _amount, "");
  }

  /// @dev Overriding `burn`
  function burn(address account, uint256 id, uint256 value) public override onlyHandler {
    super.burn(account, id, value);
    
    tokens[id].circulatingSupply -= value;
  }

  /// @dev Overriding `burnBatch`
  function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public override onlyHandler {
    super.burnBatch(account, ids, values);
    
    for(uint i = 0; i < ids.length; i++) {
      tokens[ids[i]].circulatingSupply -= values[i];
    }
  }


  /// @dev Returns and then increments `currentTokenId`
  function _tokenId(uint step) public onlyHandler returns (uint tokenId) {
    tokenId = currentTokenId;
    currentTokenId += (step + 1);
  }

  /**
   * @notice See the ERC1155 API. Returns the token URI of the token with id `tokenId`
   *
   * @param id The ERC1155 tokenId of a pack or reward token. 
   */
  function uri(uint id) public view override returns (string memory) {
    return tokens[id].uri;
  }
}