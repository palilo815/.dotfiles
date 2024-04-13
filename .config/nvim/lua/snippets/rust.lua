local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require "luasnip.util.events"
local ai = require "luasnip.nodes.absolute_indexer"
local extras = require "luasnip.extras"
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require "luasnip.extras.expand_conditions"
local postfix = require("luasnip.extras.postfix").postfix
local types = require "luasnip.util.types"
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

return {
  s("palilo", {
    t {
      "use std::io::*;",
      "",
      "struct Scanner {",
      "    it: std::str::SplitAsciiWhitespace<'static>,",
      "}",
      "",
      "impl Scanner {",
      "    fn new() -> Self {",
      "        let mut s = String::new();",
      "        stdin().read_to_string(&mut s).ok();",
      "        Self {",
      "            it: s.leak().split_ascii_whitespace(),",
      "        }",
      "    }",
      "    fn read<T: std::str::FromStr>(&mut self) -> T {",
      "        self.it.next().unwrap().parse::<T>().ok().unwrap()",
      "    }",
      "    fn read_vec<T: std::str::FromStr>(&mut self, len: usize) -> Vec<T> {",
      "        (0..len).map(|_| self.read()).collect()",
      "    }",
      "    fn read_bytes(&mut self) -> Vec<u8> {",
      "        self.it.next().unwrap().bytes().collect()",
      "    }",
      "    fn read_chars(&mut self) -> Vec<char> {",
      "        self.it.next().unwrap().chars().collect()",
      "    }",
      "    fn raw(&mut self) -> &str {",
      "        self.it.next().unwrap()",
      "    }",
      "}",
      "",
      "fn main() {",
      "    let mut sc = Scanner::new();",
      "    let mut bw = BufWriter::new(stdout().lock());",
      "}",
    },
  }),
  s("minmax", {
    t {
      "macro_rules! min {",
      "    ($x: expr) => ($x);",
      "    ($x: expr, $($z: expr), +) => (std::cmp::min($x, min!($($z), *)));",
      "}",
      "macro_rules! max {",
      "    ($x: expr) => ($x);",
      "    ($x: expr, $($z: expr), +) => (std::cmp::max($x, max!($($z), *)));",
      "}",
    },
  }),
  s("next_perm", {
    t {
      "fn next_permutation<T: std::cmp::Ord>(data: &mut [T]) -> bool {",
      "    let i = match data.windows(2).rposition(|w| w[0] < w[1]) {",
      "        Some(i) => i,",
      "        None => {",
      "            data.reverse();",
      "            return false;",
      "        }",
      "    };",
      "    let j = data.iter().rposition(|x| data[i] < *x).unwrap();",
      "    data.swap(i, j);",
      "    data[i + 1..].reverse();",
      "    true",
      "}",
    },
  }),
  s("chminmax", {
    t {
      "trait ChMinMax {",
      "    fn chmin(&mut self, x: Self) -> bool;",
      "    fn chmax(&mut self, x: Self) -> bool;",
      "}",
      "",
      "impl<T: PartialOrd> ChMinMax for T {",
      "    fn chmin(&mut self, x: Self) -> bool {",
      "        *self > x && {",
      "            *self = x;",
      "            true",
      "        }",
      "    }",
      "    fn chmax(&mut self, x: Self) -> bool {",
      "        *self < x && {",
      "            *self = x;",
      "            true",
      "        }",
      "    }",
      "}",
      "",
    },
  }),
  s("binary_gcd", {
    t {
      "trait Numeric {",
      "    fn gcd(x: Self, y: Self) -> Self;",
      "    fn lcm(x: Self, y: Self) -> Self;",
      "}",
      "",
      "macro_rules! impl_numeric {",
      "    ($($t:ty),*) => {",
      "        $(impl Numeric for $t {",
      "            fn gcd(mut u: Self, mut v: Self) -> Self {",
      "                if u == 0 || v == 0 {",
      "                    return u | v;",
      "                }",
      "                let k = {",
      "                    let i = u.trailing_zeros();",
      "                    let j = v.trailing_zeros();",
      "                    u >>= i;",
      "                    v >>= j;",
      "                    i.min(j)",
      "                };",
      "                loop {",
      "                    if u > v {",
      "                        std::mem::swap(&mut u, &mut v);",
      "                    }",
      "                    v -= u;",
      "                    if v == 0 {",
      "                        return u << k;",
      "                    }",
      "                    v >>= v.trailing_zeros();",
      "                }",
      "            }",
      "            fn lcm(u: Self, v: Self) -> Self {",
      "                u / Self::gcd(u, v) * v",
      "            }",
      "        }) *",
      "    }",
      "}",
      "",
      "impl_numeric!(i8, i16, i32, i64, i128, isize);",
      "impl_numeric!(u8, u16, u32, u64, u128, usize);",
    },
  }),
  s("parametric", {
    t {
      "let parametric = |mut lo, mut hi| {",
      "    let f = |mid| -> bool {",
      "        ",
    },
    i(2, "// TODO"),
    t {
      "",
      "    };",
      "",
    },
    c(1, {
      t {
        "    // first true",
        "    while lo != hi {",
        "        let mid = lo + (hi - lo) / 2;",
        "        if f(mid) {",
        "            hi = mid;",
        "        } else {",
        "            lo = mid + 1;",
        "        }",
        "    }",
      },
      t {
        "    // last true",
        "    while lo != hi {",
        "        let mid = hi - (hi - lo) / 2;",
        "        if f(mid) {",
        "            lo = mid;",
        "        } else {",
        "            hi = mid - 1;",
        "        }",
        "    }",
      },
    }),
    t {
      "",
      "    lo",
      "};",
      "",
    },
  }),
  s("HeapNode", {
    t {
      "#[derive(Eq, PartialEq)]",
      "struct HeapNode(u32, usize);",
      "",
      "impl std::cmp::Ord for HeapNode {",
      "    fn cmp(&self, rhs: &Self) -> std::cmp::Ordering {",
      "        rhs.0.cmp(&(self.0))",
      "        // self.0.cmp(&(rhs.0))",
      "    }",
      "}",
      "",
      "impl std::cmp::PartialOrd for HeapNode {",
      "    fn partial_cmp(&self, rhs: &Self) -> Option<std::cmp::Ordering> {",
      "        Some(self.cmp(rhs))",
      "    }",
      "}",
    },
  }),
  s("dfs_ordering", {
    t {
      "let mut topo = Vec::with_capacity(n);",
      "topo.push(0);",
      "for i in 0..n {",
      "    let u = topo[i];",
      "    for v in adj[u].clone() {",
      "        let j = adj[v].iter().position(|&x| x == u).unwrap();",
      "        adj[v].swap_remove(j);",
      "    }",
      "    topo.extend_from_slice(&adj[u]);",
      "}",
    },
  }),
  s("sss", fmt("let {} = sc.next::<{}>();", { i(1, "n"), i(2, "usize") })),
  s("ww", fmta('write!(bw, "{}", <>).ok();', i(1, "x"))),
  s("wwl", fmta('writeln!(bw, "{}", <>).ok();', i(1, "x"))),
  s("MOVE", t { "const MOVE: [(usize, usize); 4] = [(usize::MAX, 0), (0, usize::MAX), (0, 1), (1, 0)];", "" }),
  s(
    "INFINITY",
    c(1, {
      t "const INF: i32 = 0x3f3f3f3f;",
      t "const INF: u32 = 0x3f3f3f3f;",
      t "const INF: i64 = 0x3f3f3f3f3f3f3f3f;",
      t "const INF: u64 = 0x3f3f3f3f3f3f3f3f;",
    })
  ),
}
