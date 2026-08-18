import fifo_pkg::*;
class base_test;
    env_fifo env;
    virtual inf_fifo vif;

    function new (virtual inf_fifo vif);
        this.vif = vif;
    endfunction

    virtual function void build;
        env = new(vif);
        env.build();
    endfunction

    virtual task run;
        env.run();
    endtask

    function void send(fifo_op_t op, int cycle, random_t random = RANDOM, bit [31:0] data = 32'h0);
        repeat (cycle) begin
            env.gen.send(op, random, data);
        end
    endfunction

    
endclass