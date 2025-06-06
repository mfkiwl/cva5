/*
 * Copyright © 2018 Eric Matthews,  Lesley Shannon
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

package csr_types;
    import cva5_config::*;
    import riscv_types::*;

    const logic [1:0] CSR_READ_ONLY = 2'b11;

    typedef enum logic [1:0] {
        USER_PRIVILEGE = 2'b00,
        SUPERVISOR_PRIVILEGE = 2'b01,
        RESERVED_PRIVILEGE = 2'b10,
        MACHINE_PRIVILEGE = 2'b11
    } privilege_t;


    typedef struct packed {
        logic [1:0] rw_bits;
        logic [1:0] privilege;
        logic [7:0] sub_addr;
    } csr_addr_t;

    //Constant registers
    typedef struct packed {
        logic[1:0] mxlen; //RV32I
        logic[3:0] reserved;
        logic Z;
        logic Y;
        logic X;
        logic W;
        logic V;
        logic U;
        logic T;
        logic S; //Supervisor mode
        logic R;
        logic Q;
        logic P;
        logic O;
        logic N;
        logic M; //multiply divide
        logic L;
        logic K;
        logic J;
        logic I; //Base
        logic H;
        logic G;
        logic F; //Single precision
        logic E;
        logic D; //Double precision
        logic C;
        logic B;
        logic A; //Atomic
    } misa_t;

    typedef struct packed {
        logic sd;
        logic [7:0] zeros;
        logic tsr;
        logic tw;
        logic tvm;
        logic mxr;
        logic sum;
        logic mprv;
        logic [1:0] xs;
        logic [1:0] fs;
        logic [1:0] mpp;
        logic [1:0] vs;
        logic spp;
        logic mpie;
        logic ube;
        logic spie;
        logic zero2;
        logic mie;
        logic zero3;
        logic sie;
        logic zero4;
    } mstatus_t;

    typedef struct packed {
        logic [7:0] custom;
        logic [7:0] zeros;
        logic store_amo_page_fault;
        logic zero1;
        logic load_page_fault;
        logic instruction_page_fault;
        logic m_ecall;
        logic zero2;
        logic s_ecall;
        logic u_ecall;
        logic store_amo_access_fault;
        logic store_amo_misaligned;
        logic load_fault;
        logic load_misaligned;
        logic breakpoint;
        logic illegal_instruction;
        logic instruction_access_fault;
        logic instruction_misaligned;
    } medeleg_t;

    typedef struct packed {
        logic [31:16] custom;
        logic [15:14] zeros;
        logic lcofip;
        logic zero0;
        logic meip;
        logic zero1;
        logic seip;
        logic zero2;
        logic mtip;
        logic zero3;
        logic stip;
        logic zero4;
        logic msip;
        logic zero5;
        logic ssip;
        logic zero6;
    } mip_t;

    typedef struct packed {
        logic [31:16] custom;
        logic [15:14] zeros;
        logic lcofie;
        logic zero0;
        logic meie;
        logic zero1;
        logic seie;
        logic zero2;
        logic mtie;
        logic zero3;
        logic stie;
        logic zero4;
        logic msie;
        logic zero5;
        logic ssie;
        logic zero6;
    } mie_t;

    typedef struct packed {
        logic [31:16] custom;
        logic [15:14] zeros;
        logic lcofipd;
        logic [12:10] zero1;
        logic seid;
        logic [8:6] zero2;
        logic stid;
        logic [4:2] zero3;
        logic ssid;
        logic zero4;
    } mideleg_t;

    typedef struct packed {
        logic is_interrupt;
        logic [XLEN-1-1-ECODE_W:0] zeros;
        logic [ECODE_W-1:0] code;
    } cause_t;

    typedef struct packed {
        logic [28:0] hpm;
        logic ir;
        logic tm;
        logic cy;
    } mcounter_t;

    typedef struct packed {
        logic [24:0] zeros_high;
        logic cbze;
        logic cbcfe;
        logic [1:0] cbie;
        logic [1:0] zeros_low;
        logic fiom;
    } envcfg_t;

    typedef struct packed {
        logic stce;
        logic pbmte;
        logic adue;
        logic cde;
        logic [27:0] zeros;
    } envcfgh_t;

    typedef struct packed {
        logic [28:0] zeros;
        logic jvt;
        logic fcsr;
        logic c;
    } stateen0_t;

    typedef struct packed {
        logic se0;
        logic envcfg;
        logic zero;
        logic csrind;
        logic aia;
        logic imsic;
        logic contex;
        logic [24:0] zeros;
    } mstateen0h_t;

    typedef struct packed {
        logic mode;
        logic [ASIDLEN-1:0] asid;
        logic [21:0] ppn;
    } satp_t;

    typedef struct packed {
        logic d;
        logic a;
        logic g;
        logic u;
        logic x;
        logic w;
        logic r;
        logic v;
    } pte_perms_t;

endpackage
