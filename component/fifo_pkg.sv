package fifo_pkg;
    // FIFO functions
    typedef enum {
        CLEAR,
        CLEAR_READ,
        CLEAR_WRITE,
        CLEAR_READ_WRITE,
        IDLE,
        WRITE,
        READ,
        READ_WRITE
    } fifo_op_t;

    // Value mode
    typedef enum {
        RANDOM,
        MANUAL
    } random_t;
    
endpackage