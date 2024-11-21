# State-Based Methods: Refinement & Model-Based Testing

#### Goal:
- specification $\rightarrow$ design $\rightarrow$ code
    ```
       Spec         Code
    interface -> impl1, impl2
    ```
- operation refinement
- data refinement

##### Operation refinement
- Abstract operation OpA
- Concrete operation OpC

- Weaker precondition
    ```
    - pre OpA => pre OpC
    ```
    - example:
    ```
    PreA x>0
        OpA(spec, itf)
    PostA

    PreC x>-100
        OpC(impl, refined)
    PostC
    ```

- Stronger postcondition
    ```
    - post OpC => post OpA
    ```

- Analogy: inherithance & method overriding
  - Object-oriented development

##### Data refinement

- Goal: design concrete data structure
- Abstract schemas $\rightarrow$ abstract states
- Concrete schemas $\rightarrow$ concrete states
- Abstraction schema: abstract $\leftrightarrow$ concrete
- Correct data refinement
    ```
    - pre OpA ∧ Abs => pre OpC
    - pre OpA ∧ Abs ∧ OpC => Abs' ∧ post OpA
    - InitC => InitA ∧ Abs
    ```
  
-  Example:
    ```
    OpA: increase
        Pre:x>0
        Post:x'>0

    OpC: increaseImpl
        Pre: x1 > 0
        Post: x1'>0 and x1' > x1
        COde: x1' = x1 + 1

    Abstraction schema: x > 0 <==> x1 > 0

    pre OpA ∧ Abs                 => pre OpC
    x > 0 and x > 0 <==> x1 > 0   => x1 > 0
    ```

    ```
    abstract contract(specificaiton)
        Pre: x>0
        Post: x'>0
    
    Code: x_res = x+1

    Pre x>0 => SMT solver => x
    

    ```