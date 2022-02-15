
//////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2021 , Dinesh Annayya                          
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Dinesh Annayya <dinesha@opencores.org>
//
//////////////////////////////////////////////////////////////////////
////                                                              ////
////  SPI Master Top Module                                       ////
////                                                              ////
////  This file is part of the riscduino cores project            ////
////  https://github.com/dineshannayya/riscduino.git              ////
////  This block integrate the SPI Master related module          ////
////     - sspim_if                                               ////
////     - sspim_ctl                                              ////
////     - sspim_cfg                                              ////
////                                                              ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
////  Revision :                                                  ////
////    0.1 - 03 Oct 2021, Dinesh A                               ////
////          Initial SpI Module picked from                      ////
////           http://www.opencores.org/cores/turbo8051/          ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////


module sspim_top (
           input  logic         clk          ,
           input  logic         reset_n      ,          
           
           
           //---------------------------------
           // Reg Bus Interface Signal
           //---------------------------------
           input logic          reg_cs       ,
           input logic          reg_wr       ,
           input logic [7:0]    reg_addr     ,
           input logic [31:0]   reg_wdata    ,
           input logic [3:0]    reg_be       ,
           
           // Outputs
           output logic [31:0]  reg_rdata    ,
           output logic         reg_ack      ,
           
           //-------------------------------------------
           // Line Interface
           //-------------------------------------------
           
           output logic        sck           , // clock out
           output logic        so            , // serial data out
           input  logic        si            , // serial data in
           output logic        ssn             // cs_n

           );
 

//------------------------------------
// Local declration
//------------------------------------

logic [7:0]          byte_in                       ;
logic [7:0]          byte_out                      ;


logic  [1:0]         cfg_tgt_sel                   ;

logic                cfg_op_req                    ; // SPI operation request
logic  [1:0]         cfg_op_type                   ; // SPI operation type
logic  [1:0]         cfg_transfer_size             ; // SPI transfer size
logic  [5:0]         cfg_sck_period                ; // sck clock period
logic  [4:0]         cfg_sck_cs_period             ; // cs setup/hold period
logic  [7:0]         cfg_cs_byte                   ; // cs bit information
logic  [31:0]        cfg_datain                    ; // data for transfer
logic  [31:0]        cfg_dataout                   ; // data for received
logic                hware_op_done                 ; // operation done
logic [3:0]          cs_n                          ; // cs_n

assign ssn =  cs_n[0]; // Only 1 chip select supported in riscdunio

sspim_if  u_spi_if
          (
          . clk                         (clk                          ), 
          . reset_n                     (reset_n                      ),

           // towards ctrl i/f
          . sck_pe                      (sck_pe                       ),
          . sck_int                     (sck_int                      ),
          . cs_int_n                    (cs_int_n                     ),
          . byte_in                     (byte_in                      ),
          . load_byte                   (load_byte                    ),
          . byte_out                    (byte_out                     ),
          . shift_out                   (shift_out                    ),
          . shift_in                    (shift_in                     ),

          . cfg_tgt_sel                 (cfg_tgt_sel                  ),

          . sck                         (sck                          ),
          . so                          (so                           ),
          . si                          (si                           ),
          . cs_n                        (cs_n                         )
           );


sspim_ctl  u_spi_ctrl
       ( 
          . clk                         (clk                          ),
          . reset_n                     (reset_n                      ),

          . cfg_op_req                  (cfg_op_req                   ),
          . cfg_op_type                 (cfg_op_type                  ),
          . cfg_transfer_size           (cfg_transfer_size            ),
          . cfg_sck_period              (cfg_sck_period               ),
          . cfg_sck_cs_period           (cfg_sck_cs_period            ),
          . cfg_cs_byte                 (cfg_cs_byte                  ),
          . cfg_datain                  (cfg_datain                   ),
          . cfg_dataout                 (cfg_dataout                  ),
          . op_done                     (hware_op_done                ),

          . sck_int                     (sck_int                      ),
          . cs_int_n                    (cs_int_n                     ),
          . sck_pe                      (sck_pe                       ),
          . sck_ne                      (sck_ne                       ),
          . shift_out                   (shift_out                    ),
          . shift_in                    (shift_in                     ),
          . load_byte                   (load_byte                    ),
          . byte_out                    (byte_out                     ),
          . byte_in                     (byte_in                      )
         
         );




sspim_cfg u_cfg (

          . mclk                        (clk                          ),
          . reset_n                     (reset_n                      ),

        // Reg Bus Interface Signal
          . reg_cs                      (reg_cs                       ),
          . reg_wr                      (reg_wr                       ),
          . reg_addr                    (reg_addr                     ),
          . reg_wdata                   (reg_wdata                    ),
          . reg_be                      (reg_be                       ),

            // Outputs
          . reg_rdata                   (reg_rdata                    ),
          . reg_ack                     (reg_ack                      ),


           // configuration signal
          . cfg_tgt_sel                 (cfg_tgt_sel                  ),
          . cfg_op_req                  (cfg_op_req                   ), // SPI operation request
          . cfg_op_type                 (cfg_op_type                  ), // SPI operation type
          . cfg_transfer_size           (cfg_transfer_size            ), // SPI transfer size
          . cfg_sck_period              (cfg_sck_period               ), // sck clock period
          . cfg_sck_cs_period           (cfg_sck_cs_period            ), // cs setup/hold period
          . cfg_cs_byte                 (cfg_cs_byte                  ), // cs bit information
          . cfg_datain                  (cfg_datain                   ), // data for transfer
          . cfg_dataout                 (cfg_dataout                  ), // data for received
          . hware_op_done               (hware_op_done                )  // operation done

        );

endmodule
