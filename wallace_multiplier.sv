module fulladder(
    input a,b,cin,
    output sum,cout
);
assign sum=a^b^cin;
assign cout=(a&b)|(b&cin)|(cin&a);

endmodule

// 4->2 compressor i0+i1+i2+i3=sum+2(c1+c2) 
module comp4to2(
    input i0,i1,i2,i3,
    output sum,c1,c2
);

wire s;
fulladder fa1(.a(i0),.b(i1),.cin(i2),.sum(s),.cout(c1));
fulladder fa2(.a(i3),.b(s),.cin(1'b0),.sum(sum),.cout(c2));
endmodule

// compressor 7->3 i0+i1+i2+i3+i4+i5+i6= sum+2c1+4c2
module comp7to3(
    input i0,i1,i2,i3,i4,i5,i6,
    output sum,c1,c2
);

wire s_fa1, c_fa1, s_fa2, c_fa2, s_fa3, c_fa3;

fulladder fa_1 (.a(i0), .b(i1), .cin(i2), .sum(s_fa1), .cout(c_fa1));
fulladder fa_2 (.a(i3), .b(i4), .cin(i5), .sum(s_fa2),.cout(c_fa2));
fulladder fa_3 (.a(s_fa1), .b(s_fa2), .cin(i6), .sum(s_fa3), .cout(c_fa3));
fulladder fa_4 (.a(c_fa1), .b(c_fa2), .cin(c_fa3), .sum(c1), .cout(c2));

assign sum = s_fa3;

endmodule

// 3->2 array compressor similar to FA's
// just like adding 3 arrays and making a seprate array for carry
module comp3to2arr(
    input [31:0] a,b,cin,
    output [31:0] sum,cout
);

assign sum=a^b^cin;
assign cout=((a&b)|(b&cin)|(cin&a)) << 1;

endmodule

// 4->2 array compressor
module comp4to2arr(
    input [31:0] x0,x1,x2,x3,
    output [31:0] sum,cout
);
    wire [31:0] stemp,ctemp;
    comp3to2arr C3_1(.a(x0),.b(x1),.cin(x2),.sum(stemp),.cout(ctemp));
    comp3to2arr C3_2(.a(x3),.b(stemp),.cin(ctemp),.sum(sum),.cout(cout));
endmodule

// 32 bit carry look ahead adder
// faster than normal FA's
module cla_32bit(
    input  [31:0] a,b,
    input cin,
    output [31:0] sum,
    output cout
);
    wire [31:0] p, g;
    wire [32:0] c;

    assign c[0]=cin;

    assign p =a^b;
    assign g =a&b;

    genvar i;
    generate
        for (i=0;i<32;i++) begin 
            assign c[i+1] = g[i]|(p[i]&c[i]);
        end
    endgenerate

    assign sum  = p^c[31:0];
    assign cout = c[32];
endmodule


// 7->3 array compressor 
module comp7to3arr (
    input  wire [31:0] x0, x1, x2, x3, x4, x5, x6,
    output wire [31:0] s, c, c2
);
    genvar i;
    wire [31:0] c_t1,c_t2;

    generate
        for (i=0;i<32;i++) begin
            comp7to3 mjknf(
                .i0(x0[i]), .i1(x1[i]),.i2(x2[i]),
                .i3(x3[i]),.i4(x4[i]), .i5(x5[i]),.i6(x6[i]),
                .sum(s[i]), .c1(c_t1[i]),.c2(c_t2[i])
            );
        end
    endgenerate

    assign c={c_t1[30:0],1'b0};
    assign c2={c_t2[29:0],2'b00};
endmodule


module wallace_multiplier(
    input clk,
    input rst,
    input [15:0] a,b,
    output reg [31:0] p
);

 wire [31:0] pp [0:15];
// genrating partial products array
    genvar r, j;
    generate
        for (r=0;r<16;r++) begin :row
           for (j = 0;j<32;j++) begin  :col
                if(j < r)
                    assign pp[r][j] = 1'b0;
                else if(j<r + 16)
                    assign pp[r][j] = a[j - r] & b[r];
                else
                    assign pp[r][j] = 1'b0;
            end
        end
 endgenerate

// wires to handle compressed arrays
 wire [31:0] s0, c0, c02,s1, c1, c12;

// compress array using 2 7:3 compressor
comp7to3arr com1(.x0(pp[0]),.x1(pp[1]),.x2(pp[2]),
                            .x3(pp[3]),.x4(pp[4]),.x5(pp[5]),.x6(pp[6]),
                            .s(s0),.c(c0),.c2(c02));

comp7to3arr com2(.x0(pp[7]),.x1(pp[8]),.x2(pp[9]),
                            .x3(pp[10]),.x4(pp[11]),.x5(pp[12]),.x6(pp[13]),
                            .s(s1),.c(c1),.c2(c12));

 // pipeline stage 1
 // storing the resulted compressed array into registers so it will be ready at next clock cycle for next input and our current data 
// will not lost  
 reg [31:0] s0_r, s1_r, c0_r, c1_r, c02_r, c12_r, pp14_r, pp15_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s0_r<= 0; s1_r<=0; c0_r<= 0; c1_r<= 0;
            c02_r<=0; c12_r <=0; pp14_r <=0; pp15_r<= 0;
        end else begin
            s0_r<=s0; s1_r<= s1; c0_r<= c0; c1_r <=c1;
            c02_r<=c02; c12_r<=c12; pp14_r<=pp[14]; pp15_r<=pp[15];
        end
end

// compression 2nd time 

 wire [31:0] su, car, car2;
    comp7to3arr compe(.x0(s0_r),.x1(s1_r),.x2(c0_r),
                            .x3(c1_r),.x4(c02_r),.x5(c12_r),.x6(pp14_r),
                            .s(su),.c(car),.c2(car2));

// pipeline stage 2
 reg [31:0] sA_r, cA_r, cA2_r, last_r;
 always @(posedge clk or posedge rst) begin
        if (rst) begin
            sA_r <=0; cA_r<= 0; cA2_r<= 0; last_r<= 0;
        end else begin
            sA_r <=su; cA_r<=car; cA2_r <=car2; last_r<=pp15_r;
        end
 end

// compress using 4:2 comprssors bcz less than 7 arrays are remaining
wire [31:0] sum, carry;
 comp4to2arr chan(.x0(sA_r),.x1(cA_r), .x2(cA2_r),.x3(last_r),
                       .sum(sum), .cout(carry)); 

// pipeline stage 3
 reg [31:0] sum_r, carry_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum_r<= 0; carry_r <=0;
        end else begin
            sum_r <= sum; carry_r<= carry;
        end
end            

wire [31:0] sum_comb;
wire carrry;

// additon using carry look ahead adder to make addition faster than normal FA's

cla_32bit add(
    .a(sum_r),
    .b(carry_r),
    .cin(1'b0),
    .sum(sum_comb),
    .cout(carrry)
);

// assigning o/p to reg p 
always @(posedge clk or posedge rst) begin
        if (rst)
            p<= 0;
        else
            p <=sum_comb;
end
endmodule
// we have used pipeline to make multiplier faster and it will give result after each clock cycle after completion of setup time it will give consistant results

