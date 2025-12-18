
# Pipelined Wallace Tree Multiplier (SystemVerilog)

## Overview
This project implements a **pipelined 16×16 Wallace Tree Multiplier** in **SystemVerilog**.
The design improves multiplication speed by reducing partial products using
**carry-save arithmetic** and multiple stages of **compressors**, followed by a
**carry look-ahead adder (CLA)** for fast final addition.

Pipeline registers are inserted between reduction stages to achieve **high throughput**
and stable timing.

---

## Key Features
- 16-bit × 16-bit multiplication
- Wallace Tree–based partial product reduction
- Custom compressor designs:
  - Full Adder
  - 4→2 Compressor
  - 7→3 Compressor
- Array-based compression for parallel reduction
- Multi-stage pipelined architecture
- Final 32-bit Carry Look-Ahead Adder
- Fully synthesizable RTL design

---

## Design Description

### 1. Partial Product Generation
- Partial products are generated using bitwise AND between inputs `a` and `b`
- 16 partial product rows are created
- Each row is left-shifted according to the multiplier bit position
- Partial products are stored as 32-bit vectors


---

### 2. First-Level Reduction (7→3 Compression)
- Two **7→3 array compressors** are used:
  - Compressor 1 reduces pp[0]–pp[6]
  - Compressor 2 reduces pp[7]–pp[13]
- Each 7→3 compressor produces:
  - Sum
  - Carry (shifted by 1)
  - Carry² (shifted by 2)

This step significantly reduces the number of operand rows early in the Wallace Tree.

---

### 3. Pipeline Stage 1
- Outputs of first-level compressors and remaining partial products (`pp[14]`, `pp[15]`)
  are stored in registers
- Prevents data loss and enables concurrent processing of new inputs

---

### 4. Second-Level Reduction (7→3 Compression)
- A third **7→3 array compressor** reduces:
  - Sum outputs
  - Carry outputs
  - Carry² outputs
  - Remaining partial product (`pp[14]`)
- Produces three reduced operand arrays

---

### 5. Pipeline Stage 2
- Reduced operands are registered
- This stage isolates combinational delay and improves clock frequency

---

### 6. Final Reduction (4→2 Compression)
- Remaining four operands are reduced using a **4→2 array compressor**
- Produces:
  - One sum array
  - One carry array

This stage is sufficient since fewer operands remain.

---

### 7. Pipeline Stage 3
- Final sum and carry arrays are registered before final addition
- Ensures stable and synchronous inputs to the adder

---

### 8. Final Addition
- A **32-bit Carry Look-Ahead Adder (CLA)** adds the final sum and carry arrays
- Reduces carry propagation delay compared to ripple-carry adders

---

### 9. Output Register
- The final multiplication result is registered
- Output is provided synchronously on `p`

---

## Pipeline Summary
- Partial Products  
  ↓  
- 7→3 Compression  
  ↓  
- Pipeline Register  
  ↓  
- 7→3 Compression  
  ↓  
- Pipeline Register  
  ↓  
- 4→2 Compression  
  ↓  
- Pipeline Register  
  ↓  
- CLA Addition  
  ↓  
- Output Register  


After pipeline fill, the design produces **one result per clock cycle**.

---

## Implemented Modules
- `fulladder`
- `comp4to2`
- `comp7to3`
- `comp3to2arr`
- `comp4to2arr`
- `comp7to3arr`
- `cla_32bit`
- `wallace_multiplier` (top module)

---

## Performance Characteristics
- High throughput due to pipelining
- Reduced critical path using carry-save arithmetic
- Faster than array and ripple-based multipliers
- Trade-off: increased area and hardware complexity

---

## Verification
- Verified using SystemVerilog simulation
- Tested with:
  - Random input values
  - Boundary cases (zero and maximum values)
- Functional correctness confirmed

---

## Limitations
- Fixed 16×16 bit-width
- No power or area optimization
- Intended for educational use

---

## Future Improvements
- Parameterized bit-width support
- Booth encoding for fewer partial products
- Prefix adders for faster final addition
- Power and area optimization

---

## Learning Outcomes
- Understanding of Wallace Tree multiplication
- Practical experience with carry-save arithmetic
- RTL pipelining and timing optimization
- Speed–area trade-offs in digital design
