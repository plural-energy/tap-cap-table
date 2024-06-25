// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { UpgradeableBeacon } from "openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { BeaconProxy } from "openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { AccessControlDefaultAdminRules } from "openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";
import { ICapTableFactory } from "./interfaces/ICapTableFactory.sol";
import { ICapTable } from "./interfaces/ICapTable.sol";

contract CapTableFactory is ICapTableFactory, AccessControlDefaultAdminRules {
    /// @notice Thrown when the caller is not the owner
    error NotAdmin();
    /// @notice Thrown when the caller is not an operator
    error NotOperator();

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");

    address public capTableImplementation;
    UpgradeableBeacon public capTableBeacon;
    address[] public capTableProxies;

    constructor(address _capTableImplementation) AccessControlDefaultAdminRules(0, msg.sender) {
        require(_capTableImplementation != address(0), "Invalid implementation address");
        capTableImplementation = _capTableImplementation;
        capTableBeacon = new UpgradeableBeacon(capTableImplementation);

        _setRoleAdmin(OPERATOR_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function createCapTable(bytes16 id, string memory name, uint256 initial_shares_authorized) external onlyOperator returns (address) {
        require(id != bytes16(0) && initial_shares_authorized != 0, "Invalid issuer params");

        bytes memory initializationData = abi.encodeCall(ICapTable.initialize, (id, name, initial_shares_authorized, msg.sender));
        BeaconProxy capTableProxy = new BeaconProxy(address(capTableBeacon), initializationData);
        capTableProxies.push(address(capTableProxy));
        emit CapTableCreated(address(capTableProxy));
        return address(capTableProxy);
    }

    function updateCapTableImplementation(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "Invalid implementation address");
        capTableBeacon.upgradeTo(newImplementation);
        capTableImplementation = newImplementation;
    }

    function getCapTableCount() external view returns (uint256) {
        return capTableProxies.length;
    }

    modifier onlyOperator() {
        /// @notice Admins are also considered Operators
        require(hasRole(OPERATOR_ROLE, _msgSender()) || _isAdmin(), "Does not have operator role");
        _;
    }

    modifier onlyAdmin() {
        require(_isAdmin(), "Does not have admin role");
        _;
    }

    function _isAdmin() internal view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function addOperator(address addr) external onlyAdmin {
        _grantRole(OPERATOR_ROLE, addr);
    }

    function removeOperator(address addr) external onlyAdmin {
        _revokeRole(OPERATOR_ROLE, addr);
    }
}
