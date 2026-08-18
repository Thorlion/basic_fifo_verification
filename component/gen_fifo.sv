import fifo_pkg::*;
class gen_fifo;
    mailbox #(trans_fifo) mbx;
    mailbox #(int) count_mbx;
    int num_trans = 0;
    trans_fifo q [$];

    function new(mailbox #(trans_fifo) mbx, mailbox #(int) count_mbx);
        this.mbx = mbx;
        this.count_mbx = count_mbx;
    endfunction

    function void send(
        fifo_op_t op,
        random_t randomize_data = 0,
        bit [31:0] data = 32'h0
    );

        trans_fifo tx = new();

        if (randomize_data == RANDOM) begin
            assert(tx.randomize())
                else $fatal("Failed to randomize transaction");
        end
        else begin
            tx.Data_In = data;
        end

        // Set FIFO operation
        case (op)
            CLEAR: begin
                tx.FClrN = 0;
                tx.FInN  = 1;
                tx.FOutN = 1;
            end

            CLEAR_READ: begin
                tx.FClrN = 0;
                tx.FInN  = 1;
                tx.FOutN = 0;
            end

            CLEAR_WRITE: begin
                tx.FClrN = 0;
                tx.FInN  = 0;
                tx.FOutN = 1;
            end

            CLEAR_READ_WRITE: begin
                tx.FClrN = 0;
                tx.FInN  = 0;
                tx.FOutN = 0;
            end

            IDLE: begin
                tx.FClrN = 1;
                tx.FInN  = 1;
                tx.FOutN = 1;
            end

            WRITE: begin
                tx.FClrN = 1;
                tx.FInN  = 0;
                tx.FOutN = 1;
            end

            READ: begin
                tx.FClrN = 1;
                tx.FInN  = 1;
                tx.FOutN = 0;
            end

            READ_WRITE: begin
                tx.FClrN = 1;
                tx.FInN  = 0;
                tx.FOutN = 0;
            end
        endcase

        q.push_back(tx);
        num_trans++;
        $display("num_trans: %d", num_trans);
    endfunction

    task run();
        trans_fifo tr;
        while (q.size() > 0) begin
            tr = q.pop_front();
            mbx.put(tr);
        end

        count_mbx.put(num_trans);
        $display("Mailbox sent: %d transactions", num_trans);

    endtask
            
endclass