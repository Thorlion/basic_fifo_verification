class scb_fifo;
    mailbox #(trans_fifo) out_mbx;
    parameter FIFO_DEPTH = 4;
    
    int pass_count = 0;
    int error_count = 0;

    int          fcounter = 0;       
    logic [1:0]  rd_ptr   = 2'b00;   
    logic [1:0]  wr_ptr   = 2'b00;   
    logic [31:0] mem [4];          

    bit [31:0] fifo_q[$];      

    function new(mailbox #(trans_fifo) out);
        this.out_mbx = out;
    endfunction

    function trans_fifo expected(trans_fifo in_tr);
        trans_fifo exp;
        exp = new();

        // 1. Handle Reset and Clear
        if (!in_tr.FClrN) begin
            fcounter = 0;
            rd_ptr   = 2'b00;
            wr_ptr   = 2'b00;
            
            // Clear all memory slots on reset/clear
            foreach (mem[i]) mem[i] = 32'h0;
            
            // Default active-low flag states[cite: 1]
            exp.F_EmptyN = 1'b0; 
            exp.F_FirstN = 1'b1;
            exp.F_SLastN = 1'b1;
            exp.F_LastN  = 1'b1;
            exp.F_FullN  = 1'b1; 
        end 
        else begin
            bit curr_empty = (fcounter == 0);
            bit curr_full  = (fcounter == 4); 

            // 2. Memory Write (Blocked if full)
            if (!in_tr.FInN && !curr_full) begin
                mem[wr_ptr] = in_tr.Data_In;
                
                // Advance write pointer and handle wrap-back to 0
                wr_ptr++;
                if (wr_ptr == 4) begin
                    wr_ptr = 0; // Wrap back
                end
            end

            // 3. Pointer Read (Blocked if empty)
            if (!in_tr.FOutN && !curr_empty) begin
                logic [1:0] old_rd_ptr = rd_ptr;
                
                // Advance read pointer and handle wrap-back to 0
                rd_ptr++;
                if (rd_ptr == 4) begin
                    rd_ptr = 0; // Wrap back
                end

                // CLEARING LOGIC: Clear the consumed memory slot after reading
                mem[old_rd_ptr] = 32'h0; 
            end

            // 4. Update the item counter[cite: 1]
            if (!in_tr.FInN && in_tr.FOutN && !curr_full) begin
                fcounter++;
            end 
            else if (in_tr.FInN && !in_tr.FOutN && !curr_empty) begin
                fcounter--;
            end

            // 5. Predict next cycle's flags[cite: 1]
            exp.F_EmptyN = (fcounter == 0) ? 1'b0 : 1'b1;
            exp.F_FirstN = (fcounter >= 1) ? 1'b0 : 1'b1;
            exp.F_SLastN = (fcounter == 2) ? 1'b0 : 1'b1;
            exp.F_LastN  = (fcounter == 3) ? 1'b0 : 1'b1;
            exp.F_FullN  = (fcounter == 4) ? 1'b0 : 1'b1;
        end

        // 6. FWFT Data Out behavior[cite: 1]
        // Returns zero if pointing to a cleared/empty slot
        exp.F_Data = mem[rd_ptr];
        return exp;
    endfunction

    task check(trans_fifo out_tr, trans_fifo exp_tr);
        bit failed;
        failed = 0;

        if (out_tr.F_Data !== exp_tr.F_Data) begin
            $display("[SCOREBOARD] F_Data mismatch: Expected = %0h, Actual = %0h",
                    exp_tr.F_Data, out_tr.F_Data);
            failed = 1;
        end

        if (out_tr.F_EmptyN !== exp_tr.F_EmptyN) begin
            $display("[SCOREBOARD] F_EmptyN mismatch: Expected = %0b, Actual = %0b",
                    exp_tr.F_EmptyN, out_tr.F_EmptyN);
            failed = 1;
        end

        if (out_tr.F_FullN !== exp_tr.F_FullN) begin
            $display("[SCOREBOARD] F_FullN mismatch: Expected = %0b, Actual = %0b",
                    exp_tr.F_FullN, out_tr.F_FullN);
            failed = 1;
        end

        if (out_tr.F_SLastN !== exp_tr.F_SLastN) begin
            $display("[SCOREBOARD] F_SLastN mismatch: Expected = %0b, Actual = %0b",
                    exp_tr.F_SLastN, out_tr.F_SLastN);
            failed = 1;
        end

        if (out_tr.F_LastN !== exp_tr.F_LastN) begin
            $display("[SCOREBOARD] F_LastN mismatch: Expected = %0b, Actual = %0b",
                    exp_tr.F_LastN, out_tr.F_LastN);
            failed = 1;
        end

        if (out_tr.F_FirstN !== exp_tr.F_FirstN) begin
            $display("[SCOREBOARD] F_FirstN mismatch: Expected = %0b, Actual = %0b",
                    exp_tr.F_FirstN, out_tr.F_FirstN);
            failed = 1;
        end

        if (failed) begin
            error_count++; 
            $error("[SCOREBOARD] [FAILED] Transaction failed");
        end
        else begin
            pass_count++;
            $display("[SCOREBOARD] [PASS] All data and flags match.");
        end
    endtask

    // Main run task
    task run();
        trans_fifo exp_tr;
        trans_fifo out_tr;

        $display("[SCOREBOARD] Started...");
        
        forever begin
            out_mbx.get(out_tr);
            exp_tr = expected(out_tr);

            $display("------------------------------------------------------------");
            $display("[SCOREBOARD] Transaction. Time = %0t", $time);
            $display("  INPUT: Write=%0b Read=%0b Clr=%0b Data_In=%0h" ,
                    !out_tr.FInN,
                    !out_tr.FOutN,
                    !out_tr.FClrN,
                    out_tr.Data_In);
            $display("  MONITOR : Data=%0h EmptyN=%0b FullN=%0b FirstN=%0b SLastN=%0b LastN=%0b ",
                    out_tr.F_Data,
                    !out_tr.F_EmptyN,
                    !out_tr.F_FullN,
                    !out_tr.F_FirstN,
                    !out_tr.F_SLastN,
                    !out_tr.F_LastN);

            $display("  EXPECTED: Data=%0h EmptyN=%0b FullN=%0b FirstN=%0b SLastN=%0b LastN=%0b",
                    exp_tr.F_Data,
                    !exp_tr.F_EmptyN,
                    !exp_tr.F_FullN,
                    !exp_tr.F_FirstN,
                    !exp_tr.F_SLastN,
                    !exp_tr.F_LastN);

            check(out_tr, exp_tr);
        end
    endtask

    function void print_summary();
        $display("=======================================");
        $display("          SCOREBOARD SUMMARY           ");
        $display("=======================================");
        $display(" Total Matches: %0d", pass_count);
        $display(" Total Errors : %0d", error_count);
        $display("=======================================");
    endfunction

endclass