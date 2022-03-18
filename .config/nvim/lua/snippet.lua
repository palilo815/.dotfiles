-- If you're reading this file for the first time, best skip to around line 190
-- where the actual snippet-definitions start.

local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")


-- Every unspecified option will be set to the default.
ls.config.set_config({
	history = true,
	-- Update more often, :h events for more info.
	updateevents = "TextChanged,TextChangedI",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "choiceNode", "Comment" } },
			},
		},
	},
	-- treesitter-hl has 100, use something higher (default is 200).
	ext_base_prio = 300,
	-- minimal increase in priority.
	ext_prio_increase = 1,
	enable_autosnippets = true,
})

-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
	return args[1]
end

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
		})
	)
end

-- complicated function for dynamicNode.
local function jdocsnip(args, _, old_state)
	-- !!! old_state is used to preserve user-input here. DON'T DO IT THAT WAY!
	-- Using a restoreNode instead is much easier.
	-- View this only as an example on how old_state functions.
	local nodes = {
		t({ "/**", " * " }),
		i(1, "A short Description"),
		t({ "", "" }),
	}

	-- These will be merged with the snippet; that way, should the snippet be updated,
	-- some user input eg. text can be referred to in the new snippet.
	local param_nodes = {}

	if old_state then
		nodes[2] = i(1, old_state.descr:get_text())
	end
	param_nodes.descr = nodes[2]

	-- At least one param.
	if string.find(args[2][1], ", ") then
		vim.list_extend(nodes, { t({ " * ", "" }) })
	end

	local insert = 2
	for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
		-- Get actual name parameter.
		arg = vim.split(arg, " ", true)[2]
		if arg then
			local inode
			-- if there was some text in this parameter, use it as static_text for this new snippet.
			if old_state and old_state[arg] then
				inode = i(insert, old_state["arg" .. arg]:get_text())
			else
				inode = i(insert)
			end
			vim.list_extend(
				nodes,
				{ t({ " * @param " .. arg .. " " }), inode, t({ "", "" }) }
			)
			param_nodes["arg" .. arg] = inode

			insert = insert + 1
		end
	end

	if args[1][1] ~= "void" then
		local inode
		if old_state and old_state.ret then
			inode = i(insert, old_state.ret:get_text())
		else
			inode = i(insert)
		end

		vim.list_extend(
			nodes,
			{ t({ " * ", " * @return " }), inode, t({ "", "" }) }
		)
		param_nodes.ret = inode
		insert = insert + 1
	end

	if vim.tbl_count(args[3]) ~= 1 then
		local exc = string.gsub(args[3][2], " throws ", "")
		local ins
		if old_state and old_state.ex then
			ins = i(insert, old_state.ex:get_text())
		else
			ins = i(insert)
		end
		vim.list_extend(
			nodes,
			{ t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) }
		)
		param_nodes.ex = ins
		insert = insert + 1
	end

	vim.list_extend(nodes, { t({ " */" }) })

	local snip = sn(nil, nodes)
	-- Error on attempting overwrite.
	snip.old_state = param_nodes
	return snip
end

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function bash(_, _, command)
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end

-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
local date_input = function(args, state, fmt)
	local fmt = fmt or "%Y-%m-%d"
	return sn(nil, i(1, os.date(fmt)))
end

ls.snippets = {
	-- When trying to expand a snippet, luasnip first searches the tables for
	-- each filetype specified in 'filetype' followed by 'all'.
	-- If ie. the filetype is 'lua.c'
	--     - luasnip.lua
	--     - luasnip.c
	--     - luasnip.all
	-- are searched in that order.

	c = {
		s("palilo", {
			t({
                "#include <bits/stdc++.h>",
                "",
                "int main() {",
                "    using namespace std;",
                "    cin.tie(nullptr)->sync_with_stdio(false);",
                "#ifdef palilo",
                "    freopen(\"in\", \"r\", stdin);",
                "    freopen(\"out\", \"w\", stdout);",
                "#endif",
                "\t",
            }),
            i(1),
            t({"", "}"}),
		}),
        s("parametric", {
            t({
                "auto parametric = [&]<typename T>(T lo, T hi) {",
                "\tauto f = [&](T mid) -> bool {",
                "\t\t",
            }),
			i(2, "// TODO"),
            t({
                "",
                "\t};",
                "",
            }),
			c(1, {
                t({
                    "\t// first true",
                    "\twhile (lo != hi) {",
                    "\t\tauto mid = lo + (hi - lo) / 2;",
                    "\t\tf(mid) ? hi = mid : lo = mid + 1;",
                    "\t}",
                }),
                t({
                    "\t// last true",
                    "\twhile (lo != hi) {",
                    "\t\tauto mid = hi - (hi - lo) / 2;",
                    "\t\tf(mid) ? lo = mid : hi = mid - 1;",
                    "\t}",
                }),
			}),
            t({
                "",
                "\treturn lo;",
                "};"
            }),
		}),
        s("y_combinator", {
			t({
                "namespace std {",
                "// http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2016/p0200r0.html",
                "template <class Fun>",
                "class y_combinator_result {",
                "    Fun fun_;",
                "",
                "public:",
                "    template <class T>",
                "    explicit y_combinator_result(T&& fun) : fun_(std::forward<T>(fun)) {}",
                "",
                "    template <class... Args>",
                "    decltype(auto) operator()(Args&&... args) {",
                "        return fun_(std::ref(*this), std::forward<Args>(args)...);",
                "    }",
                "};",
                "",
                "template <class Fun>",
                "decltype(auto) y_combinator(Fun&& fun) {",
                "    return y_combinator_result<std::decay_t<Fun>>(std::forward<Fun>(fun));",
                "}",
                "}; // namespace std",
            }),
		}),
        s("chminmax", {
			t({
                "template <class T>",
			    "bool chmin(T& _old, T _new) { return _old > _new && (_old = _new, true); }",
			    "template <class T>",
			    "bool chmax(T& _old, T _new) { return _old < _new && (_old = _new, true); }",
            })
		}),
		
        s("MOVE", {
			t("constexpr array<pair<int, int>, 4> MOVE {{{-1, 0}, {0, -1}, {0, 1}, {1, 0}}};")
		}),
	},
    rust = {
		s("fio_scanner", {
			t({
                "use std::io::*;",
                "",
                "struct Scanner<'a> {",
                "    it: std::str::SplitWhitespace<'a>,",
                "}",
                "",
                "impl<'a> Scanner<'a> {",
                "    fn new(s: &'a str) -> Scanner<'a> {",
                "        Scanner {",
                "            it: s.split_whitespace(),",
                "        }",
                "    }",
                "    fn next<T: std::str::FromStr>(&mut self) -> T {",
                "        self.it.next().unwrap().parse::<T>().ok().unwrap()",
                "    }",
                "    fn next_bytes(&mut self) -> Vec<u8> {",
                "        self.it.next().unwrap().bytes().collect()",
                "    }",
                "    fn next_chars(&mut self) -> Vec<char> {",
                "        self.it.next().unwrap().chars().collect()",
                "    }",
                "    fn next_vec<T: std::str::FromStr>(&mut self, len: usize) -> Vec<T> {",
                "        (0..len).map(|_| self.next()).collect()",
                "    }",
                "}",
                "",
                "fn main() {",
                "    let mut s = String::new();",
                "    stdin().read_to_string(&mut s).unwrap();",
                "    let mut sc = Scanner::new(&s);",
                "    let out = stdout();",
                "    let mut out = BufWriter::new(out.lock());",
                "    run(&mut sc, &mut out);",
                "}",
                "",
                "fn run<W: Write>(sc: &mut Scanner, out: &mut BufWriter<W>) {",
                "",
                "}",
            }),
		}),
		s("fio_input", {
			t({
                "macro_rules! input {",
                "    (source = $s:expr, $($r:tt)*) => {",
                "        let mut iter = $s.split_whitespace();",
                "        input_inner!{iter, $($r)*}",
                "    };",
                "    ($($r:tt)*) => {",
                "        let s = {",
                "            use std::io::Read;",
                "            let mut s = String::new();",
                "            std::io::stdin().read_to_string(&mut s).unwrap();",
                "            s",
                "        };",
                "        let mut iter = s.split_whitespace();",
                "        input_inner!{iter, $($r)*}",
                "    };",
                "}",
                "",
                "macro_rules! input_inner {",
                "    ($iter:expr) => {};",
                "    ($iter:expr, ) => {};",
                "    ($iter:expr, $var:ident:$t:tt $($r:tt)*) => {",
                "        let $var = read_value!($iter, $t);",
                "        input_inner!{$iter $($r)*}",
                "    };",
                "}",
                "",
                "macro_rules! read_value {",
                "    ($iter:expr, ($($t:tt), *)) => {",
                "        ($(read_value!($iter, $t)), *)",
                "    };",
                "    ($iter:expr, [$t:tt; $len:expr]) => {",
                "        (0..$len).map(|_| read_value!($iter, $t)).collect::<Vec<_>>()",
                "    };",
                "    ($iter:expr, chars) => {",
                "        read_value!($iter, String).chars().collect::<Vec<char>>()",
                "    };",
                "    ($iter:expr, bytes) => {",
                "        read_value!($iter, String).bytes().collect::<Vec<u8>>()",
                "    };",
                "    ($iter:expr, usize1) => {",
                "        read_value!($iter, usize) - 1",
                "    };",
                "    ($iter:expr, $t:ty) => {",
                "        $iter.next().unwrap().parse::<$t>().expect(\"Parse error\")",
                "    };",
                "}",
                "",
                "fn main() {",
                "    use std::io::Write;",
                "    let out = std::io::stdout();",
                "    let mut out = std::io::BufWriter::new(out.lock());",
                "    input! {",
                "        n: usize,",
                "    }",
                "}",
            }),
        }),
        s("minmax", {
            t({
                "macro_rules! min {",
                "    ($x: expr) => ($x);",
                "    ($x: expr, $($z: expr), +) => (std::cmp::min($x, min!($($z), *)));",
                "}",
                "macro_rules! max {",
                "    ($x: expr) => ($x);",
                "    ($x: expr, $($z: expr), +) => (std::cmp::max($x, max!($($z), *)));",
                "}",
            }),
        }),
        s("next_perm", {
            t({
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
            }),
        }),
        s("chminmax", {
            t({
                "trait ChMinMax {",
                "\tfn chmin(&mut self, x: Self) -> bool;",
                "\tfn chmax(&mut self, x: Self) -> bool;",
                "}",
                "",
                "impl<T: PartialOrd> ChMinMax for T {",
                "\tfn chmin(&mut self, x: Self) -> bool {",
                "\t\t*self > x && {",
                "\t\t\t*self = x;",
                "\t\t\ttrue",
                "\t\t}",
                "\t}",
                "\tfn chmax(&mut self, x: Self) -> bool {",
                "\t\t*self < x && {",
                "\t\t\t*self = x;",
                "\t\t\ttrue",
                "\t\t}",
                "\t}",
                "}",
                "",
            }),
        }),
        s("binary_gcd", {
            t({
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
            }),
        }),
        s("parametric", {
            t({
                "let parametric = |mut lo, mut hi| {",
                "\tlet f = |mid| -> bool {",
                "\t\t",
            }),
			i(2, "// TODO"),
            t({
                "",
                "\t};",
                "",
            }),
			c(1, {
                t({
                    "\t// first true",
                    "\twhile lo != hi {",
                    "\t\tlet mid = lo + (hi - lo) / 2;",
                    "\t\tif f(mid) {",
                    "\t\t\thi = mid;",
                    "\t\t} else {",
                    "\t\t\tlo = mid + 1;",
                    "\t\t}",
                    "\t}",
                }),
                t({
                    "\t// last true",
                    "\twhile lo != hi {",
                    "\t\tlet mid = hi - (hi - lo) / 2;",
                    "\t\tif f(mid) {",
                    "\t\t\tlo = mid;",
                    "\t\t} else {",
                    "\t\t\thi = mid - 1;",
                    "\t\t}",
                    "\t}",
                }),
			}),
            t({
                "",
                "\tlo",
                "};",
                "",
            }),
		}),
		s("chminmax", {
			t({
                "template <class T>",
			    "bool chmin(T& _old, T _new) { return _old > _new && (_old = _new, true); }",
			    "template <class T>",
			    "bool chmax(T& _old, T _new) { return _old < _new && (_old = _new, true); }",
            })
		}),
        s("HeapNode", {
            t({
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
            }),
        }),
        s("sss", fmt("let {} = sc.next::<{}>();", {i(1, "n"), i(2, "usize")})),
        s("ww", fmta("write!(out, \"{}\", <>).ok();", i(1, "x"))),
        s("wwl", fmta("writeln!(out, \"{}\", <>).ok();", i(1, "x"))),
        s("MOVE", t({"const MOVE: [(usize, usize); 4] = [(usize::MAX, 0), (0, usize::MAX), (0, 1), (1, 0)];", ""})),
        s("INFINITY", c(1, {
            t("const INF: i32 = 0x3f3f3f3f;"),
            t("const INF: u32 = 0x3f3f3f3f;"),
            t("const INF: i64 = 0x3f3f3f3f3f3f3f3f;"),
            t("const INF: u64 = 0x3f3f3f3f3f3f3f3f;"),
        })),
	},
    java = {
		-- trigger is fn.
		s("fn", {
			-- Simple static text.
			t("//Parameters: "),
			-- function, first parameter is the function, second the Placeholders
			-- whose text it gets as input.
			f(copy, 2),
			t({ "", "function " }),
			-- Placeholder/Insert.
			i(1),
			t("("),
			-- Placeholder with initial text.
			i(2, "int foo"),
			-- Linebreak
			t({ ") {", "\t" }),
			-- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
			i(0),
			t({ "", "}" }),
		}),
		s("class", {
			-- Choice: Switch between two different Nodes, first parameter is its position, second a list of nodes.
			c(1, {
				t("public "),
				t("private "),
			}),
			t("class "),
			i(2),
			t(" "),
			c(3, {
				t("{"),
				-- sn: Nested Snippet. Instead of a trigger, it has a position, just like insert-nodes. !!! These don't expect a 0-node!!!!
				-- Inside Choices, Nodes don't need a position as the choice node is the one being jumped to.
				sn(nil, {
					t("extends "),
					-- restoreNode: stores and restores nodes.
					-- pass position, store-key and nodes.
					r(1, "other_class", i(1)),
					t(" {"),
				}),
				sn(nil, {
					t("implements "),
					-- no need to define the nodes for a given key a second time.
					r(1, "other_class"),
					t(" {"),
				}),
			}),
			t({ "", "\t" }),
			i(0),
			t({ "", "}" }),
		}),
		-- Alternative printf-like notation for defining snippets. It uses format
		-- string with placeholders similar to the ones used with Python's .format().
		s(
			"fmt1",
			fmt("To {title} {} {}.", {
				i(2, "Name"),
				i(3, "Surname"),
				title = c(1, { t("Mr."), t("Ms.") }),
			})
		),
		-- To escape delimiters use double them, e.g. `{}` -> `{{}}`.
		-- Multi-line format strings by default have empty first/last line removed.
		-- Indent common to all lines is also removed. Use the third `opts` argument
		-- to control this behaviour.
		s(
			"fmt2",
			fmt(
				[[
			foo({1}, {3}) {{
				return {2} * {4}
			}}
			]],
				{
					i(1, "x"),
					rep(1),
					i(2, "y"),
					rep(2),
				}
			)
		),
		-- Empty placeholders are numbered automatically starting from 1 or the last
		-- value of a numbered placeholder. Named placeholders do not affect numbering.
		s(
			"fmt3",
			fmt("{} {a} {} {1} {}", {
				t("1"),
				t("2"),
				a = t("A"),
			})
		),
		-- The delimiters can be changed from the default `{}` to something else.
		s(
			"fmt4",
			fmt("foo() { return []; }", i(1, "x"), { delimiters = "[]" })
		),
		-- `fmta` is a convenient wrapper that uses `<>` instead of `{}`.
		s("fmt5", fmta("foo() { return <>; }", i(1, "x"))),
		-- By default all args must be used. Use strict=false to disable the check
		s(
			"fmt6",
			fmt("use {} only", { t("this"), t("not this") }, { strict = false })
		),
		-- Use a dynamic_node to interpolate the output of a
		-- function (see date_input above) into the initial
		-- value of an insert_node.
		s("novel", {
			t("It was a dark and stormy night on "),
			d(1, date_input, {}, "%A, %B %d of %Y"),
			t(" and the clocks were striking thirteen."),
		}),
		-- Parsing snippets: First parameter: Snippet-Trigger, Second: Snippet body.
		-- Placeholders are parsed into choices with 1. the placeholder text(as a snippet) and 2. an empty string.
		-- This means they are not SELECTed like in other editors/Snippet engines.
		ls.parser.parse_snippet(
			"lspsyn",
			"Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"
		),

		-- When wordTrig is set to false, snippets may also expand inside other words.
		ls.parser.parse_snippet(
			{ trig = "te", wordTrig = false },
			"${1:cond} ? ${2:true} : ${3:false}"
		),

		-- When regTrig is set, trig is treated like a pattern, this snippet will expand after any number.
		ls.parser.parse_snippet({ trig = "%d", regTrig = true }, "A Number!!"),
		-- Using the condition, it's possible to allow expansion only in specific cases.
		s("cond", {
			t("will only expand in c-style comments"),
		}, {
			condition = function(line_to_cursor, matched_trigger, captures)
				-- optional whitespace followed by //
				return line_to_cursor:match("%s*//")
			end,
		}),
		-- there's some built-in conditions in "luasnip.extras.expand_conditions".
		s("cond2", {
			t("will only expand at the beginning of the line"),
		}, {
			condition = conds.line_begin,
		}),
		-- The last entry of args passed to the user-function is the surrounding snippet.
		s(
			{ trig = "a%d", regTrig = true },
			f(function(_, snip)
				return "Triggered with " .. snip.trigger .. "."
			end, {})
		),
		-- It's possible to use capture-groups inside regex-triggers.
		s(
			{ trig = "b(%d)", regTrig = true },
			f(function(_, snip)
				return "Captured Text: " .. snip.captures[1] .. "."
			end, {})
		),
		s({ trig = "c(%d+)", regTrig = true }, {
			t("will only expand for even numbers"),
		}, {
			condition = function(line_to_cursor, matched_trigger, captures)
				return tonumber(captures[1]) % 2 == 0
			end,
		}),
		-- Use a function to execute any shell command and print its text.
		s("bash", f(bash, {}, "ls")),
		-- Short version for applying String transformations using function nodes.
		s("transform", {
			i(1, "initial text"),
			t({ "", "" }),
			-- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
			-- This list will be applied in order to the first node given in the second argument.
			l(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
		}),
		s("transform2", {
			i(1, "initial text"),
			t("::"),
			i(2, "replacement for e"),
			t({ "", "" }),
			-- Lambdas can also apply transforms USING the text of other nodes:
			l(l._1:gsub("e", l._2), { 1, 2 }),
		}),
		s({ trig = "trafo(%d+)", regTrig = true }, {
			-- env-variables and captures can also be used:
			l(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
		}),
		-- Set store_selection_keys = "<Tab>" (for example) in your
		-- luasnip.config.setup() call to access TM_SELECTED_TEXT. In
		-- this case, select a URL, hit Tab, then expand this snippet.
		s("link_url", {
			t('<a href="'),
			f(function(_, snip)
				return snip.env.TM_SELECTED_TEXT[1] or {}
			end, {}),
			t('">'),
			i(1),
			t("</a>"),
			i(0),
		}),
		-- Shorthand for repeating the text in a given node.
		s("repeat", { i(1, "text"), t({ "", "" }), rep(1) }),
		-- Directly insert the ouput from a function evaluated at runtime.
		s("part", p(os.date, "%Y")),
		-- use matchNodes to insert text based on a pattern/function/lambda-evaluation.
		s("mat", {
			i(1, { "sample_text" }),
			t(": "),
			m(1, "%d", "contains a number", "no number :("),
		}),
		-- The inserted text defaults to the first capture group/the entire
		-- match if there are none
		s("mat2", {
			i(1, { "sample_text" }),
			t(": "),
			m(1, "[abc][abc][abc]"),
		}),
		-- It is even possible to apply gsubs' or other transformations
		-- before matching.
		s("mat3", {
			i(1, { "sample_text" }),
			t(": "),
			m(
				1,
				l._1:gsub("[123]", ""):match("%d"),
				"contains a number that isn't 1, 2 or 3!"
			),
		}),
		-- `match` also accepts a function, which in turn accepts a string
		-- (text in node, \n-concatted) and returns any non-nil value to match.
		-- If that value is a string, it is used for the default-inserted text.
		s("mat4", {
			i(1, { "sample_text" }),
			t(": "),
			m(1, function(text)
				return (#text % 2 == 0 and text) or nil
			end),
		}),
		-- The nonempty-node inserts text depending on whether the arg-node is
		-- empty.
		s("nempty", {
			i(1, "sample_text"),
			n(1, "i(1) is not empty!"),
		}),
		-- dynamic lambdas work exactly like regular lambdas, except that they
		-- don't return a textNode, but a dynamicNode containing one insertNode.
		-- This makes it easier to dynamically set preset-text for insertNodes.
		s("dl1", {
			i(1, "sample_text"),
			t({ ":", "" }),
			dl(2, l._1, 1),
		}),
		-- Obviously, it's also possible to apply transformations, just like lambdas.
		s("dl2", {
			i(1, "sample_text"),
			i(2, "sample_text_2"),
			t({ "", "" }),
			dl(3, l._1:gsub("\n", " linebreak ") .. l._2, { 1, 2 }),
		}),
		-- Very long example for a java class.
		s("fn", {
			d(6, jdocsnip, { 2, 4, 5 }),
			t({ "", "" }),
			c(1, {
				t("public "),
				t("private "),
			}),
			c(2, {
				t("void"),
				t("String"),
				t("char"),
				t("int"),
				t("double"),
				t("boolean"),
				i(nil, ""),
			}),
			t(" "),
			i(3, "myFunc"),
			t("("),
			i(4),
			t(")"),
			c(5, {
				t(""),
				sn(nil, {
					t({ "", " throws " }),
					i(1),
				}),
			}),
			t({ " {", "\t" }),
			i(0),
			t({ "", "}" }),
		}),
	},
	tex = {
		-- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
		-- \item as necessary by utilizing a choiceNode.
		s("ls", {
			t({ "\\begin{itemize}", "\t\\item " }),
			i(1),
			d(2, rec_ls, {}),
			t({ "", "\\end{itemize}" }),
		}),
	},
}

-- autotriggered snippets have to be defined in a separate table, luasnip.autosnippets.
ls.autosnippets = {
	all = {
		s("autotrigger", {
			t("autosnippet"),
		}),
	},
}

-- in a lua file: search lua-, then c-, then all-snippets.
-- ls.filetype_extend("lua", { "c" })
-- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
ls.filetype_set("cpp", { "c" })
