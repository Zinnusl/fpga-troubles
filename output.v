

module top(clock,led);
    
    // Module arguments
    input wire  clock;
    output reg  [5:0] led;
    
    // Stub signals
    reg  pulser$clock;
    reg  pulser$enable;
    wire  pulser$pulse;
    
    // Local signals
    reg  [5:0] num;
    
    // Sub module instances
    top$pulser pulser(
        .clock(pulser$clock),
        .enable(pulser$enable),
        .pulse(pulser$pulse)
    );
    
    // Update code
    always @(*) begin
        pulser$clock = clock;
        pulser$enable = 1'b1;
        num = ((pulser$pulse) & 6'h3f);
        led = num + 32'h1;
        num = led + 32'h1;
    end
    
endmodule // top


module top$pulser(clock,enable,pulse);
    
    // Module arguments
    input wire  clock;
    input wire  enable;
    output reg  pulse;
    
    // Stub signals
    reg  strobe$enable;
    wire  strobe$strobe;
    reg  strobe$clock;
    reg  shot$trigger;
    wire  shot$active;
    reg  shot$clock;
    wire  shot$fired;
    
    // Sub module instances
    top$pulser$strobe strobe(
        .enable(strobe$enable),
        .strobe(strobe$strobe),
        .clock(strobe$clock)
    );
    top$pulser$shot shot(
        .trigger(shot$trigger),
        .active(shot$active),
        .clock(shot$clock),
        .fired(shot$fired)
    );
    
    // Update code
    always @(*) begin
        strobe$clock = clock;
        shot$clock = clock;
        strobe$enable = enable;
        shot$trigger = strobe$strobe;
        pulse = shot$active;
    end
    
endmodule // top$pulser


module top$pulser$shot(trigger,active,clock,fired);
    
    // Module arguments
    input wire  trigger;
    output reg  active;
    input wire  clock;
    output reg  fired;
    
    // Constant declarations
    localparam  duration = 32'h2932e0;
    
    // Stub signals
    reg  [31:0] counter$d;
    wire  [31:0] counter$q;
    reg  counter$clock;
    reg  state$d;
    wire  state$q;
    reg  state$clock;
    
    // Sub module instances
    top$pulser$shot$counter counter(
        .d(counter$d),
        .q(counter$q),
        .clock(counter$clock)
    );
    top$pulser$shot$state state(
        .d(state$d),
        .q(state$q),
        .clock(state$clock)
    );
    
    // Update code
    always @(*) begin
        counter$clock = clock;
        state$clock = clock;
        counter$d = counter$q;
        state$d = state$q;
        if (state$q) begin
            counter$d = counter$q + 32'h1;
        end
        fired = 1'b0;
        if (state$q && (counter$q == duration)) begin
            state$d = 1'b0;
            fired = 1'b1;
        end
        active = state$q;
        if (trigger) begin
            state$d = 1'b1;
            counter$d = 32'h0;
        end
    end
    
endmodule // top$pulser$shot


module top$pulser$shot$counter(d,q,clock);
    
    // Module arguments
    input wire  [31:0] d;
    output reg  [31:0] q;
    input wire  clock;
    
    // Update code (custom)
    initial begin
       q = 32'h0;
    end
    
    always @(posedge clock) begin
       q <= d;
    end
          
endmodule // top$pulser$shot$counter


module top$pulser$shot$state(d,q,clock);
    
    // Module arguments
    input wire  d;
    output reg  q;
    input wire  clock;
    
    // Update code (custom)
    initial begin
       q = 1'h0;
    end
    
    always @(posedge clock) begin
       q <= d;
    end
          
endmodule // top$pulser$shot$state


module top$pulser$strobe(enable,strobe,clock);
    
    // Module arguments
    input wire  enable;
    output reg  strobe;
    input wire  clock;
    
    // Constant declarations
    localparam  threshold = 32'h19bfcc0;
    
    // Stub signals
    reg  [31:0] counter$d;
    wire  [31:0] counter$q;
    reg  counter$clock;
    
    // Sub module instances
    top$pulser$strobe$counter counter(
        .d(counter$d),
        .q(counter$q),
        .clock(counter$clock)
    );
    
    // Update code
    always @(*) begin
        counter$clock = clock;
        counter$d = counter$q;
        if (enable) begin
            counter$d = counter$q + 32'h1;
        end
        strobe = enable & (counter$q == threshold);
        if (strobe) begin
            counter$d = 32'h1;
        end
    end
    
endmodule // top$pulser$strobe


module top$pulser$strobe$counter(d,q,clock);
    
    // Module arguments
    input wire  [31:0] d;
    output reg  [31:0] q;
    input wire  clock;
    
    // Update code (custom)
    initial begin
       q = 32'h0;
    end
    
    always @(posedge clock) begin
       q <= d;
    end
          
endmodule // top$pulser$strobe$counter
