%builtins range_check bitwise

from utils.eth_transaction import EthTransaction
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy

func test__decode{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}() {
    alloc_locals;
    // Given
    tempvar data_len: felt;
    let (data) = alloc();
    %{
        ids.data_len = len(program_input["data"])
        segments.write_arg(ids.data, program_input["data"])
    %}

    let (
        msg_hash: Uint256,
        nonce: felt,
        gas_price: felt,
        gas_limit: felt,
        destination: felt,
        amount: felt,
        chain_id: felt,
        payload_len: felt,
        payload: felt*,
    ) = EthTransaction.decode(data_len, data);

    tempvar output: felt*;
    %{ ids.output = output %}
    assert [output] = msg_hash.low;
    assert [output + 1] = msg_hash.high;
    assert [output + 2] = nonce;
    assert [output + 3] = gas_price;
    assert [output + 4] = gas_limit;
    assert [output + 5] = destination;
    assert [output + 6] = amount;
    assert [output + 7] = chain_id;
    assert [output + 8] = payload_len;
    memcpy(output + 9, payload, payload_len);

    return ();
}

func test__validate{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}() {
    // Given
    tempvar address: felt;
    tempvar nonce: felt;
    tempvar r: Uint256;
    tempvar s: Uint256;
    tempvar v: felt;
    tempvar tx_data_len: felt;
    let (tx_data) = alloc();
    %{
        ids.address = program_input["address"]
        ids.nonce = program_input["nonce"]
        ids.r.low = program_input["r"][0]
        ids.r.high = program_input["r"][1]
        ids.s.low = program_input["s"][0]
        ids.s.high = program_input["s"][1]
        ids.v = program_input["v"]
        ids.tx_data_len = len(program_input["tx_data"])
        segments.write_arg(ids.tx_data, program_input["tx_data"])
    %}

    // When
    EthTransaction.validate(address, nonce, r, s, v, tx_data_len, tx_data);

    return ();
}
