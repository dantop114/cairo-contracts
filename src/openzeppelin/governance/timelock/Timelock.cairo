# SPDX-License-Identifier: MIT
# OpenZeppelin Contracts for Cairo v0.1.0 (governance/timelock/Timelock.cairo)

%lang starknet

from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from openzeppelin.utils.constants import IERC721_RECEIVER_ID, TRUE, FALSE

from openzeppelin.introspection.ERC165 import ERC165_supports_interface, ERC165_register_interface

from openzeppelin.governance.timelock.library import Timelock, TimelockCall

from openzeppelin.utils.constants import (
    TIMELOCK_ADMIN_ROLE,
    PROPOSER_ROLE,
    CANCELLER_ROLE,
    EXECUTOR_ROLE,
)
from openzeppelin.access.accesscontrol import (
    _grantRole,
    _setRoleAdmin,
    AccessControl_hasRole,
    AccessControl_onlyRole,
    AccessControl_grantRole,
    AccessControl_revokeRole,
    AccessControl_initializer,
    AccessControl_renounceRole,
    AccessControl_getRoleAdmin,
)

# Constants

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    proposer : felt, executor : felt, delay : felt
):
    alloc_locals

    ERC165_register_interface(IERC721_RECEIVER_ID)

    AccessControl_initializer()
    Timelock.initializer(delay)

    _setRoleAdmin(TIMELOCK_ADMIN_ROLE, TIMELOCK_ADMIN_ROLE)
    _setRoleAdmin(PROPOSER_ROLE, TIMELOCK_ADMIN_ROLE)
    _setRoleAdmin(CANCELLER_ROLE, TIMELOCK_ADMIN_ROLE)
    _setRoleAdmin(EXECUTOR_ROLE, TIMELOCK_ADMIN_ROLE)

    let (caller) = get_caller_address()
    let (this) = get_contract_address()

    _grantRole(TIMELOCK_ADMIN_ROLE, this)
    _grantRole(TIMELOCK_ADMIN_ROLE, caller)

    _grantRole(PROPOSER_ROLE, proposer)
    _grantRole(CANCELLER_ROLE, proposer)
    _grantRole(EXECUTOR_ROLE, executor)

    return ()
end

@view
func isOperation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
    is_operation : felt
):
    let (is_operation) = Timelock.is_operation(id)

    return (is_operation=is_operation)
end

@view
func isOperationPending{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
) -> (is_pending : felt):
    let (is_pending) = Timelock.is_operation_pending(id)

    return (is_pending=is_pending)
end

@view
func isOperationReady{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
) -> (is_ready : felt):
    let (is_ready) = Timelock.is_operation_ready(id)

    return (is_ready=is_ready)
end

@view
func isOperationDone{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    id : felt
) -> (is_done : felt):
    let (is_done) = Timelock.is_operation_done(id)

    return (is_done=is_done)
end

@view
func getTimestamp{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
    timestamp : felt
):
    let (timestamp) = Timelock.get_timestamp(id)

    return (timestamp=timestamp)
end

@view
func getMinDelay{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    min_delay : felt
):
    let (min_delay) = Timelock.get_min_delay()

    return (min_delay=min_delay)
end

@view
func hashOperation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    call_array_len : felt,
    call_array : TimelockCall*,
    calldata_len : felt,
    calldata : felt*,
    predecessor : felt,
    salt : felt,
) -> (hash : felt):
    let (hash) = Timelock.hash_operation(call_array_len, call_array, calldata, predecessor, salt)

    return (hash=hash)
end

@view
func hasRole{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, user : felt
) -> (hasRole : felt):
    return AccessControl_hasRole(role, user)
end

@view
func getRoleAdmin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt
) -> (admin : felt):
    return AccessControl_getRoleAdmin(role)
end

@external
func schedule{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    call_array_len : felt,
    call_array : TimelockCall*,
    calldata_len : felt,
    calldata : felt*,
    predecessor : felt,
    salt : felt,
    delay : felt,
):
    AccessControl_onlyRole(PROPOSER_ROLE)
    Timelock.schedule(call_array_len, call_array, calldata_len, calldata, predecessor, salt, delay)

    return ()
end

@external
func cancel{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt):
    AccessControl_onlyRole(CANCELLER_ROLE)
    Timelock.cancel(id)

    return ()
end

@external
func execute{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    call_array_len : felt,
    call_array : TimelockCall*,
    calldata_len : felt,
    calldata : felt*,
    predecessor : felt,
    salt : felt,
):
    let (zero_has_role : felt) = AccessControl_hasRole(EXECUTOR_ROLE, 0)

    if zero_has_role == FALSE:
        AccessControl_onlyRole(EXECUTOR_ROLE)

        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    else:
        tempvar syscall_ptr = syscall_ptr
        tempvar pedersen_ptr = pedersen_ptr
        tempvar range_check_ptr = range_check_ptr
    end

    Timelock.execute(call_array_len, call_array, calldata_len, calldata, predecessor, salt)

    return ()
end

@external
func updateDelay{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    new_delay : felt
):
    AccessControl_onlyRole(TIMELOCK_ADMIN_ROLE)
    Timelock.set_min_delay(new_delay)

    return ()
end

@external
func grantRole{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, account : felt
):
    AccessControl_grantRole(role, account)

    return ()
end

@external
func revokeRole{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    role : felt, account : felt
):
    AccessControl_revokeRole(role, account)

    return ()
end

@external
func renounceRole{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(role : felt):
    let (caller) = get_caller_address()

    AccessControl_renounceRole(role, caller)

    return ()
end

@view
func onERC721Received(
    operator : felt, from_ : felt, tokenId : Uint256, data_len : felt, data : felt*
) -> (selector : felt):
    return (IERC721_RECEIVER_ID)
end

@view
func supportsInterface{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    interfaceId : felt
) -> (success : felt):
    let (success) = ERC165_supports_interface(interfaceId)
    return (success)
end
