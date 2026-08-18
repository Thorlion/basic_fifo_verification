class scb_fifo #(parameter bit DISPLAY_ALL = 1'b0);
    mailbox #(trans_fifo) in_mbx;
    fifo_model model;
    int unsigned pass_count  = 0;
    int unsigned error_count = 0;
    int unsigned check_count = 0;
    bit completed = 0;

    function new(mailbox #(trans_fifo) in_mbx);
        this.in_mbx = in_mbx;
        model = new();
    endfunction

    task run();
        trans_fifo actual;
        trans_fifo expected;

        completed = 0;
        $display("[SCOREBOARD] Started");

        forever begin
            in_mbx.get(actual);

            // A null transaction is the monitor's end-of-stream marker.
            if (actual == null)
                break;

            check(actual);
        end

        completed = 1;
    endtask

    // Call compare function and update pass/error count
    function void check(trans_fifo actual);
        trans_fifo expected;
        bit matched;

        expected = model.predict(actual);
        check_count++;

        if (DISPLAY_ALL)
            display_transaction(actual, expected, model.data_valid);

        matched = compare(actual, expected, model.data_valid);

        if (matched) begin
            pass_count++;
        end
        else begin
            error_count++;
            $error("[SCOREBOARD] Check %0d failed at time %0t", check_count, $time);
        end
    endfunction

    // Display every checked transaction when DISPLAY_ALL is enabled.
    function void display_transaction(
        trans_fifo actual,
        trans_fifo expected,
        bit data_valid
    );
        $display("------------------------------------------------------------");
        $display("[SCOREBOARD] Transaction no.%0d at time %0t", check_count, $time);
        $display("  Request  : Write=%0b Read=%0b Clear=%0b Data_In=%0h",
                 !actual.FInN, !actual.FOutN, !actual.FClrN, actual.Data_In);
        $display("  Data valid: %0b", data_valid);
        $display("  Signals  : Data       EmptyN FirstN SLastN LastN FullN");
        $display("  Expected : %08h     %0b      %0b       %0b      %0b     %0b",
                 expected.F_Data, expected.F_EmptyN,
                 expected.F_FirstN, expected.F_SLastN,
                 expected.F_LastN, expected.F_FullN);
        $display("  Actual   : %08h     %0b      %0b       %0b      %0b     %0b",
                 actual.F_Data, actual.F_EmptyN,
                 actual.F_FirstN, actual.F_SLastN,
                 actual.F_LastN, actual.F_FullN);
    endfunction

    // Compare data and print out failed transactions
    function bit compare(trans_fifo actual, trans_fifo expected, bit data_valid);
        logic [4:0] actual_flags;
        logic [4:0] expected_flags;

        actual_flags = {
            actual.F_EmptyN,
            actual.F_FirstN,
            actual.F_SLastN,
            actual.F_LastN,
            actual.F_FullN
        };
        expected_flags = {
            expected.F_EmptyN,
            expected.F_FirstN,
            expected.F_SLastN,
            expected.F_LastN,
            expected.F_FullN
        };

        compare = 1;

        if (actual_flags !== expected_flags) begin
            $display("[SCOREBOARD] Transaction no.%0d flag mismatch", check_count);
            $display("  Signals  : EmptyN FirstN SLastN LastN FullN");
            $display("  Expected :   %0b      %0b       %0b      %0b     %0b",
                     expected.F_EmptyN, expected.F_FirstN,
                     expected.F_SLastN, expected.F_LastN, expected.F_FullN);
            $display("  Actual   :   %0b      %0b       %0b      %0b     %0b",
                     actual.F_EmptyN, actual.F_FirstN,
                     actual.F_SLastN, actual.F_LastN, actual.F_FullN);
            compare = 0;
        end

        // F_Data is unspecified while the FIFO is empty.
        if (data_valid && actual.F_Data !== expected.F_Data) begin
            $display("[SCOREBOARD] Transaction no.%0d data mismatch: expected=%0h actual=%0h",
                     check_count, expected.F_Data, actual.F_Data);
            compare = 0;
        end
    endfunction

    // Scoreboard summary
    function void print_summary();
        $display("=======================================");
        $display("          SCOREBOARD SUMMARY");
        $display("=======================================");
        $display(" Total Checks  : %0d", check_count);
        $display(" Total Matches : %0d", pass_count);
        $display(" Total Errors  : %0d", error_count);
        $display("=======================================");
    endfunction
endclass
