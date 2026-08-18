`timescale 1ns/1ps
module tb_top_fifo;
    base_test test;
    string test_name;


    logic Clk;
    logic Rst_N;

    // Interface instance
    inf_fifo vif(Clk, Rst_N);

    fifo dut (
        .Clk      (vif.Clk),
        .RstN     (vif.Rst_N),

        .Data_In  (vif.Data_In),
        .FClrN    (vif.FClrN),
        .FInN     (vif.FInN),
        .FOutN    (vif.FOutN),

        .F_Data   (vif.F_Data),
        .F_FullN  (vif.F_FullN),
        .F_LastN  (vif.F_LastN),
        .F_SLastN (vif.F_SLastN),
        .F_FirstN (vif.F_FirstN),
        .F_EmptyN (vif.F_EmptyN)
    );

    initial begin
    forever #5 Clk = ~Clk;
    end

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_top_fifo);
    end

    initial begin 
        Rst_N = 0;
        Clk = 1;
        vif.FClrN <= 1'b1;  
        vif.FInN <= 1'b1;   
        vif.FOutN <= 1'b1; 
        @(negedge Clk);
        Rst_N = 1;
        #100;
        if (!$value$plusargs("TESTNAME=%s", test_name)) begin
            test_name = "base_test_fifo";
        end

        else if (test_name == "single_rnw") begin
            test = single_rnw::new(vif);
        end
        
        else if (test_name == "single_rw") begin
            test = single_rw::new(vif);
        end

        else if (test_name == "multiple_rnw") begin
            test = multiple_rnw::new(vif);
        end

        else if (test_name == "multiple_rw") begin
            test = multiple_rw::new(vif);
        end

        else if (test_name == "read_empty") begin
            test = read_empty::new(vif);
        end

        else if (test_name == "write_full") begin
            test = write_full::new(vif);
        end

        else if (test_name == "rw_empty") begin
            test = rw_empty::new(vif);
        end

        else if (test_name == "rw_full") begin
            test = rw_full::new(vif);
        end

        else if (test_name == "firstn") begin
            test = firstn::new(vif);
        end

        else if (test_name == "slastn") begin
            test = slastn::new(vif);
        end

        else if (test_name == "lastn") begin
            test = lastn::new(vif);
        end

         else if (test_name == "clr") begin
            test = clr::new(vif);
        end

        else if (test_name == "clr_read") begin
            test = clr_read::new(vif);
        end

        else if (test_name == "clr_write") begin
            test = clr_write::new(vif);
        end

        else if (test_name == "clr_rw") begin
            test = clr_rw::new(vif);
        end


        else begin
            test = base_test::new(vif);
        end

        test.build();
        test.run();
        #100;
        //wait(test.env.scb.pass_count + test.env.scb.error_count == test.env.gen.num_trans);
        test.env.scb.print_summary();
        $finish;
    end
endmodule