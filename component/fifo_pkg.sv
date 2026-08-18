package fifo_pkg;
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

    typedef enum {
        RANDOM,
        MANUAL
    } random_t;
endpackage