### Boolean
ok true
ok !false
ok yes
ok on
ok !off
ok !no

throws 'invalid assign on line 1' -> LiveScript.compile 'yes = 6'

### Numbers

eq 3-4, -1

# Decimal
eq 1.0, 0.0 + -0.25 - -0.75 + 0.5
eq 2011_04_24, 20110424

# Hex
eq 255, 0xff
eq 0xB_C__D___, 0xBCD

# With radix
ok 2~101010 == 8~0644/10 == 42
eq 36~O_o, 888

# With comment
eq 1year * 365.25days * 24hours, 8766_total_hours
eq 36, 0XF + 36RT
eq 100m2, 10m ** 2
eq 3000c, 30$ * 100
eq 36rpm 36

# [#31](https://github.com/satyr/coco/issues/31): Numeric Ranges
eq '1,2,3'  String [1 to +3]
eq '1,0,-1' String Array 1 to -1 by -1

til = String
eq 2, [Number]0 til 2

throws 'range limit exceeded on line 1' -> LiveScript.tokens '0 to 1 by 1e-5'
throws 'empty range on line 3'          -> LiveScript.tokens '\n\n 1 to 0'

# [coffee#764](https://github.com/jashkenas/coffee-script/issues/764)
# Boolean/Number should be indexable.
ok 42['toString']
ok true['toString']


### Arrays

a = [((x) -> x), ((x) -> x * x)]
eq a.length, 2

sum  = 0
sum += n for n in [
  1, 2, 3,
  4  5  6
  7, 8  9
]
eq sum, 45


# Trailing commas.
eq '1,2' String [1, 2,]


# Funky indentation within non-comma-seperated arrays.
result = [['a']
 {b: 'c'}]

eq 'a', result.0.0
eq 'c', result.1.b


#### Words
eq '<[ quoted words ]>', <[ <[ quoted words ]\> ]>.join ' '
eq \\ <[\]>0
eq 0  <[ ]>length


#### Implicit arrays
o =
  atom:
    0
  list:
    1
    2
eq 0 o.atom
eq 2 o.list.length

a =
  3
a =
  a, 4
a =
  ...a
eq '3,4' ''+a

points =
   *  x: 0
      y: 1
   *  x: 2, y: 3
eq 0 points.0.x
eq 3 points.1.y

I2 =
  * 1 0
  * 0 1
eq I2.0.0, I2.1.1
eq I2.0.1, I2.1.0

a = [] <<<
  0, 1
  2; 3
a +=
  4
  5
eq '0,1,2,3,4,5' ''+a

eq '0,1' ''+ do ->
  return
    0, 1
try throw
  2, 3
catch
  eq '2,3' ''+e


### Objects

o = {k1: "v1", k2: 4, k3: (-> true),}
ok o.k3() and o.k2 is 4 and o.k1 is "v1"

eq 10, {a: Number}.a 10

moe = {
  name:  'Moe'
  greet: (salutation) ->
    salutation + " " + @name
  hello: ->
    @['greet'] "Hello"
  10: 'number'
}
eq moe.hello() ,"Hello Moe"
eq moe[10]     ,'number'

moe.hello = -> this['greet'] "Hello"
eq moe.hello(), 'Hello Moe'


# Keys can include keywords.
obj = {
  is  :  -> true,
  not :  -> false,
}
ok obj.is()
ok not obj.not()

obj = {class: 'hot'}
obj.function = 'dog'
eq obj.class + obj.function, 'hotdog'


# Property shorthands.
new
  a = 0; @b = 1; x = {a, @b, 2, \3, +4, -5}
  eq x.a, 0
  eq x.b, 1
  eq x.2, 2
  eq x.3, \3
  eq x.4, true
  eq x.5, false
  c = null; d = 0; y = {a || 1, @b && 2, c ? 3, d !? 4}
  eq y.a, 1
  eq y.b, 2
  eq y.c, 3
  eq y.d, 4
  z = {true, false, on, off, yes, no, null, void, undefined, this, arguments, eval, -super, +debugger}
  eq z.true      , true
  eq z.false     , false
  eq z.on        , on
  eq z.off       , off
  eq z.yes       , yes
  eq z.no        , no
  eq z.null      , null
  eq z.void      , void
  eq z.undefined , undefined
  eq z.this      , this
  eq z.arguments , arguments
  eq z.eval      , eval
  eq z.super     , false
  eq z.debugger  , true


# [coffee#542](https://github.com/jashkenas/coffee-script/issues/542):
# Objects leading expression statement should be parenthesized.
{f: -> ok true }.f() + 1


# [#19](https://github.com/satyr/coco/issues/19)
throws 'duplicate property name "a" on line 1'
, -> LiveScript.compile '{a, b, a}'

throws 'duplicate property name "0" on line 1'
, -> LiveScript.compile '{0, "0"}'

throws 'duplicate property name "1" on line 1'
, -> LiveScript.compile '{1, 1.0}'


#### Implicit/Braceless

config =
  development:
    server: 'localhost'
    timeout: 10

  production:
    server: 'dreamboat'
    timeout: 1000

eq config.development.server  ,'localhost'
eq config.production.server   ,'dreamboat'
eq config.development.timeout ,10
eq config.production.timeout  ,1000

o =
  a: 1
  b: 2, c: d: 3
  e: f:
    'g': 4
  0: 5

eq '1,2,3,4,5' String [o.a, o.b, o.c.d, o.e.f.g, o.0]

# Implicit call should step over INDENT after `:`.
o = Object a:
  b: 2,
  c: 3,

eq 6, o.a.b * o.a.c


/* Top-level braceless object */
obj: 1
/* doesn't break things. */


# With number arguments.
k: eq 1, 1


# With wacky indentations.
obj =
  'reverse': (obj) ->
    Array.prototype.reverse.call obj
  abc: ->
    @reverse(
      @reverse @reverse ['a', 'b', 'c'].reverse()
    )
  one: [1, 2,
    a: 'b'
  3, 4]
  red:
    orange:
          yellow:
                  green: 'blue'
    indigo: 'violet'
  oddent: [[],
   [],
      [],
   []]

eq obj.abc() + ''   ,'a,b,c'
eq obj.one.length   ,5
eq obj.one[4]       ,4
eq obj.one[2].a     ,'b'
eq obj.red.indigo   ,'violet'
eq obj.oddent + '' ,',,,'
eq obj.red.orange.yellow.green, 'blue'
eq 2, (key for key of obj.red).length


# As part of chained calls.
pick = -> it.$
eq 9, pick pick pick $: $: $: 9


# [coffee#618](https://github.com/jashkenas/coffee-script/issues/618):
# Should not consume shorthand properties.
a = Array do
  1: 2
  3
eq 2, a.length
eq 2, (Array 1: 2, 3).length


# With leading comments.
obj =
  /* comment one */
  /* comment two */
  one: 1, two: 2
  fun: -> [zero: 0; three: @one + @two][1]

eq obj.fun().three, 3

# [coffee#1871](https://github.com/jashkenas/coffee-script/issues/1871),
# [coffee#1903](https://github.com/jashkenas/coffee-script/issues/1903):
# Should close early when inline.
o = p: 0
q: 1
o = q: 1 if false
ok \q not of o


# Inline with assignment/import.
o =
  p: t =   q: 0
  r: t <<< s: 1
eq o.p, o.r
eq o.p.q, 0
eq o.r.s, 1


#### Dynamic Keys
i = 0
o = splat: 'me'
obj = {
  /* leading comment  */
  (4 * 2): 8
  /* cached shorthand */
  (++i)
  (--i) or 'default value'
  /*      splat       */
  ...o
  ...{splatMe: 'too'}
  /*   normal keys    */
  key: ok
  's': ok
  0.5: ok

  "#{'interpolated'}":
    """#{"nested"}""": 123: 456
  /* traling comment  */
}
eq obj.interpolated.nested[123], 456
eq obj[8], 8
eq obj[1], 1
eq obj[0], 'default value'
eq obj.splat  , 'me'
eq obj.splatMe, 'too'
ok obj.key is obj.s is obj[1/2]

eq 'braceless dynamic key',
  (key for key of """braceless #{ 0 of ((0):(0)) and 'dynamic' } key""": 0)[0]

obj =
  one: 1
  (1 + 2 * 4): 9
eq obj[9], 9, 'trailing dynamic property should be braced as well'

obj.key = 'val'
obj.val = ok
{(obj.key)} = obj
eq ok, obj.key

{(frontness?)}


### `void`
eq void, [][0]
eq undefined, [][0]
eq void+'', 'undefined'

eq [,,].length, 2

[, a, , b,] = [2 3 5 7]
eq a * b, 21

eq 11, ((, a) -> a)(, 11)

### JS Literal

eq '\\`', `
  // Inline JS
  "\\\`"
`

i = 3
`LABEL:`
while --i then while --i then `break LABEL`
eq i, 1

`not` = -> !it
eq false `not` true


### String/Array multiplication
x = \x
n = 4
eq ''    'x'*0
eq \x    'x'*1
eq \xx   "x"*2
eq \xxx  \x *3
eq \xxxx \x *n
eq ''    "#{x}" * 0
eq \x    "#{x}" * 1
eq \xx   "#{x}" * 2
eq \xxx  "#{x}" * 3
eq \xxxx "#{x}" * n

i = -1
eq ''    ''+ [i++]*0
eq '0'   ''+ [i++]*1
eq '1,1' ''+ [i++]*2
eq '2,3,2,3,2,3' ''+ [i++, i++] * 3
eq '4,5,4,5,4,5' ''+ [i++, i++] * (n-1)

a = [1]
eq '0,1,0,1' ''+ [0 ...a] * 2
eq '1,1,1,1' ''+ [  ...a] * n


### ACI
eq null null
eq \1 \1
eq 2 [{} {}].length
eq 3*[4] 12
eq '0,true,2,3' String [0 true \2 (3)]

o = {0 \1 \2 3 4 (5)}
eq o.1, \1
eq o.3, 3
eq o.5, 5


### Misc
throws \unimplemented -> ...
