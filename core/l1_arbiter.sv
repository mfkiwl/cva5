/*
 * Copyright © 2017-2020 Eric Matthews,  Lesley Shannon
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Initial code developed under the supervision of Dr. Lesley Shannon,
 * Reconfigurable Computing Lab, Simon Fraser University.
 *
 * Author(s):
 *             Eric Matthews <ematthew@sfu.ca>
 */

module l1_arbiter

    import cva5_config::*;
    import riscv_types::*;
    import cva5_types::*;
    import l2_config_and_types::*;

    # (
        parameter cpu_config_t CONFIG = EXAMPLE_CONFIG
    )

    (
        input logic clk,
        input logic rst,

        l2_requester_interface.master l2,

        output sc_complete,
        output sc_success,

        l1_arbiter_request_interface.slave l1_request[L1_CONNECTIONS-1:0],
        l1_arbiter_return_interface.slave l1_response[L1_CONNECTIONS-1:0]
    );

    l2_request_t [L1_CONNECTIONS-1:0] l2_requests;

    logic [L1_CONNECTIONS-1:0] requests;
    logic [L1_CONNECTIONS-1:0] acks;
    logic [((L1_CONNECTIONS == 1) ? 0 : ($clog2(L1_CONNECTIONS)-1)) : 0] arb_sel;

    logic fifos_full;
    logic request_exists;
    ////////////////////////////////////////////////////
    //Implementation

    //Interface to array
    generate for (genvar i = 0; i < L1_CONNECTIONS; i++) begin : gen_requests
        assign requests[i] = l1_request[i].request;
        assign l1_request[i].ack = acks[i];
    end endgenerate

    //Always accept L2 data
    assign l2.rd_data_ack = l2.rd_data_valid;

    //Always accept store-conditional result
    assign sc_complete = CONFIG.INCLUDE_AMO & l2.con_valid;
    assign sc_success = CONFIG.INCLUDE_AMO & l2.con_result;

    //Arbiter can pop address FIFO at a different rate than the data FIFO, so check that both have space.
    assign fifos_full = l2.request_full | l2.data_full;
    assign request_exists = |requests;

    assign l2.request_push = request_exists & ~fifos_full;

    ////////////////////////////////////////////////////
    //Dcache Specific
    assign l2.wr_data_push = l2.request_push & ~l2.rnw;
    assign l2.wr_data = l1_request[L1_DCACHE_ID].data;
    assign l2.wr_data_be = l1_request[L1_DCACHE_ID].be;

    assign l2.inv_ack = CONFIG.DCACHE.USE_EXTERNAL_INVALIDATIONS ? l1_response[L1_DCACHE_ID].inv_ack : l2.inv_valid;
    assign l1_response[L1_DCACHE_ID].inv_addr = l2.inv_addr;
    assign l1_response[L1_DCACHE_ID].inv_valid = CONFIG.DCACHE.USE_EXTERNAL_INVALIDATIONS & l2.inv_valid;

    ////////////////////////////////////////////////////
    //Interface mapping
    generate for (genvar i = 0; i < L1_CONNECTIONS; i++) begin : gen_l2_requests
        assign l2_requests[i] = '{
            addr : l1_request[i].addr[31:2],
            rnw : l1_request[i].rnw,
            is_amo : l1_request[i].is_amo,
            amo_type_or_burst_size : l1_request[i].size,
            sub_id : L2_SUB_ID_W'(i)
        };
    end endgenerate

    ////////////////////////////////////////////////////
    //Arbitration
    logic [$clog2(L1_CONNECTIONS)-1:0] state;
    logic [$clog2(L1_CONNECTIONS)-1:0] muxes [L1_CONNECTIONS-1:0];

    always_ff @(posedge clk) begin
        if (rst)
            state <= 0;
        else if (l2.request_push)
            state <= arb_sel;
    end
    always_comb begin
        for (int i = 0; i < L1_CONNECTIONS; i++) begin
            muxes[i] = $clog2(L1_CONNECTIONS)'(i);
            for (int j = 0; j < L1_CONNECTIONS; j++) begin
                if (requests[(i + j) % L1_CONNECTIONS])
                    muxes[i] = $clog2(L1_CONNECTIONS)'((i + j) % L1_CONNECTIONS);
            end
        end
    end
    assign arb_sel = muxes[state];

    assign acks = L1_CONNECTIONS'(l2.request_push) << arb_sel;

    assign l2.addr = l2_requests[arb_sel].addr;
    assign l2.rnw = l2_requests[arb_sel].rnw;
    assign l2.is_amo = l2_requests[arb_sel].is_amo;
    assign l2.amo_type_or_burst_size = l2_requests[arb_sel].amo_type_or_burst_size;
    assign l2.sub_id = l2_requests[arb_sel].sub_id;

    generate for (genvar i = 0; i < L1_CONNECTIONS; i++) begin : gen_l1_responses
        assign l1_response[i].data = l2.rd_data;
        assign l1_response[i].data_valid = l2.rd_data_valid & (l2.rd_sub_id == i);
    end endgenerate

endmodule
