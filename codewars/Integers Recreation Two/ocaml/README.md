# Algorithm Explanation

## The issue: Very unclear Kata description

* I missed the "each taken only once".
* That means, you can only have solutions as:

```ruby
    e²     +     f²
(ac ± bd)² + (ad ± bc)²
```


## Different case scenarios

Hypothesis 1:
`(ac + bd)² + (ad - bc)²`
OR
`(ac - bd)² + (ad + bc)²`

Hypothesis 2:
`(ac + bd)² + (ad + bc)²`
OR
`(ac - bd)² + (ad - bc)²`

### Hypothesis 1: one sign positive, one sign negative

First case, we must resolve:
```ruby
        (a²+b²) * (c²+d²) == e² + f²
        (a²+b²) * (c²+d²) == (ac+bd)² + (ad-bc)²
a²c² + a²d² + b²c² + b²d² == a²c² + 2abcd + b²d² + a²d² - 2abcd + b²c²
a²c² + a²d² + b²c² + b²d² == a²c² + b²d² + a²d² + b²c²
                        0 == 0
```
ALWAYS TRUE

Second case, we must resolve:
```ruby
        (a²+b²) * (c²+d²) == e² + f²
        (a²+b²) * (c²+d²) == (ac-bd)² + (ad+bc)²
a²c² + a²d² + b²c² + b²d² == a²c² - 2abcd + b²d² + a²d² + 2abcd + b²c²
a²c² + a²d² + b²c² + b²d² == a²c² + b²d² + a²d² + b²c²
                        0 == 0
```
ALWAYS TRUE

=> Those two cases are always solutions to the problem.

Solution 1: `e, f = (ac+bd), (ad-bc)`
Solution 2: `e, f = (ac-bd), (ad+bc)`

### Hypothesis 2: the two signs are the same

First case, we must resolve:
```ruby
        (a²+b²) * (c²+d²) == e² + f²
        (a²+b²) * (c²+d²) == (ac+bd)² + (ad+bc)²
a²c² + a²d² + b²c² + b²d² == a²c² + 2abcd + b²d² + a²d² + 2abcd + b²c²
                        0 == 4abcd
```
TRUE IF `a`, `b`, `c` or `d` `== 0`

Second case, we must resolve:
```ruby
        (a²+b²) * (c²+d²) == e² + f²
        (a²+b²) * (c²+d²) == (ac-bd)² + (ad-bc)²
a²c² + a²d² + b²c² + b²d² == a²c² - 2abcd + b²d² + a²d² - 2abcd + b²c²
                    4abcd == 0
```
TRUE IF `a`, `b`, `c` or `d` `== 0`

#### Case a == 0

```ruby
e² + f² == (ac-bd)² + (ad-bc)²
e² + f² == (-bd)² + (-bc)²

...
e, f = -bd + bc
```

=> This is the Solution 2 of Hypothesis 1

#### Case b == 0

```ruby
e² + f² == (ac-bd)² + (ad-bc)²
e² + f² == (ac)² + (ad)²

...
e, f = ac + ad
```

#### Case c == 0 and d == 0

As with `a == 0` and `b == 0`, the solutions are always solutions from the Hypothesis

## Conclusion

Whatever the case is, we only have the two same solutions to this problem:
Solution 1: `[ac+bd, ad-bc]`
Solution 2: `[ac-bd, ad+bc]`

If those two solutions are identical, then we have only one solution.
