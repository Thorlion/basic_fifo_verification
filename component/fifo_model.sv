class fifo_model;
    localparam int unsigned FIFO_DEPTH = 4;

    bit [31:0] model_q[$];
    bit data_valid;

    // Provisional FIFO contract:
    // - write-only is ignored when full
    // - read-only is ignored when empty
    // - simultaneous read/write replaces the oldest item without changing
    //   occupancy; when empty, it is treated as a no-op
    function trans_fifo predict(trans_fifo actual);
        trans_fifo expected;
        bit write_req;
        bit read_req;
        bit [31:0] discarded_data;
        int unsigned occupancy;

        expected = new();
        write_req = !actual.FInN;
        read_req  = !actual.FOutN;

        if (!actual.Rst_N || !actual.FClrN) begin
            model_q.delete();
        end
        else begin
            case ({write_req, read_req})
                // Write only
                2'b10: begin
                    if (model_q.size() < FIFO_DEPTH)
                        model_q.push_back(actual.Data_In);
                end
                
                // Read only
                2'b01: begin
                    if (model_q.size() > 0)
                        discarded_data = model_q.pop_front();
                end

                //Read and Write
                2'b11: begin
                    if (model_q.size() > 0) begin
                        discarded_data = model_q.pop_front();
                        model_q.push_back(actual.Data_In);
                    end
                end

                // Idle: the reference model does not change
                default: begin
                end
            endcase
        end

        occupancy = model_q.size();

        // All status outputs are active-low.
        expected.F_EmptyN = (occupancy != 0);
        expected.F_FirstN = (occupancy < 1);
        expected.F_SLastN = (occupancy != FIFO_DEPTH - 2);
        expected.F_LastN  = (occupancy != FIFO_DEPTH - 1);
        expected.F_FullN  = (occupancy != FIFO_DEPTH);

        data_valid = (occupancy > 0);
        if (data_valid)
            expected.F_Data = model_q[0];
        else
            expected.F_Data = 'x;

        return expected;
    endfunction

    
endclass