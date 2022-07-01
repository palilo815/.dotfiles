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

-- If you're reading this file for the first time, best skip to around line 190
-- where the actual snippet-definitions start.

-- Every unspecified option will be set to the default.
ls.config.set_config({
	history = true,
	-- Update more often, :h events for more info.
	update_events = "TextChanged,TextChangedI",
	-- Snippets aren't automatically removed if their text is deleted.
	-- `delete_check_events` determines on which events (:h events) a check for
	-- deleted snippets is performed.
	-- This can be especially useful when `history` is enabled.
	delete_check_events = "TextChanged",
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
	-- mapping for cutting selected text so it's usable as SELECT_DEDENT,
	-- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
	store_selection_keys = "<Tab>",
	-- luasnip uses this function to get the currently active filetype. This
	-- is the (rather uninteresting) default, but it's possible to use
	-- eg. treesitter for getting the current filetype by setting ft_func to
	-- require("luasnip.extras.filetype_functions").from_cursor (requires
	-- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
	-- the current filetype in eg. a markdown-code block or `vim.cmd()`.
	ft_func = function()
		return vim.split(vim.bo.filetype, ".", true)
	end,
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
local date_input = function(args, snip, old_state, fmt)
	local fmt = fmt or "%Y-%m-%d"
	return sn(nil, i(1, os.date(fmt)))
end

-- snippets are added via ls.add_snippets(filetype, snippets[, opts]), where
-- opts may specify the `type` of the snippets ("snippets" or "autosnippets",
-- for snippets that should expand directly after the trigger is typed).
--
-- opts can also specify a key. By passing an unique key to each add_snippets, it's possible to reload snippets by
-- re-`:luafile`ing the file in which they are defined (eg. this one).
ls.add_snippets("cpp", {
    s("palilo", {
        t({
            "#include <bits/stdc++.h>",
            "",
            "auto main() -> int {",
            "    using namespace std;",
            "    cin.tie(nullptr)->sync_with_stdio(false);",
            "\t",
        }),
        i(1),
        t({"", "}"}),
    }),
    s("parametric", {
        t({
            "auto parametric = [&]<typename T>(T lo, T hi) {",
            "    auto f = [&](T mid) -> bool {",
            "        ",
        }),
        i(2, "// TODO"),
        t({
            "",
            "    };",
            "",
        }),
        c(1, {
            t({
                "    // first true",
                "    while (lo != hi) {",
                "        auto mid = lo + (hi - lo) / 2;",
                "        f(mid) ? hi = mid : lo = mid + 1;",
                "    }",
            }),
            t({
                "    // last true",
                "    while (lo != hi) {",
                "        auto mid = hi - (hi - lo) / 2;",
                "        f(mid) ? lo = mid : hi = mid - 1;",
                "    }",
            }),
        }),
        t({
            "",
            "    return lo;",
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
    s("dfs_ordering", {
        t({
            "auto topo = [&](int root) {",
            "    vector<int> stk = {root}, topo(n);",
            "    for (auto& u : topo) {",
            "        u = stk.back();",
            "        stk.pop_back();",
            "        for (const auto& v : adj[u]) {",
            "            const auto it = find(adj[v].begin(), adj[v].end(), u);",
            "            swap(*it, adj[v].back());",
            "            adj[v].pop_back();",
            "            stk.emplace_back(v);",
            "        }",
            "    }",
            "    // reverse(topo.begin(), topo.end());",
            "    return topo;",
            "}(0);",
        })
    }),
    s("chminmax", {
        t({
            "template <class T>",
            "bool chmin(T& _old, T _new) { return _old > _new && (_old = _new, true); }",
            "template <class T>",
            "bool chmax(T& _old, T _new) { return _old < _new && (_old = _new, true); }",
        })
    }),
    s("next_bitset", {
        t({
            "auto next_bitset = [](const auto x) {",
            "    const auto c {x & -x};",
            "    const auto r {x + c};",
            "    return (((x ^ r) >> 2) / c) | r;",
            "};",
        })
    }),
    s("MOVE", {
        t("constexpr std::array<std::pair<int, int>, 4> MOVE {{{-1, 0}, {0, -1}, {0, 1}, {1, 0}}};")
    }),
    s("DEBUG", {
        t({
            "#ifdef palilo",
            "template <typename C, typename T = typename std::enable_if<!std::is_same<C, std::string>::value, typename C::value_type>::type>",
            "std::ostream& operator<<(std::ostream& os, const C& container) {",
            "    os << '[';",
            "    bool first = true;",
            "    for (const auto& x : container) {",
            "        if (!first) os << \", \";",
            "        os << x;",
            "        first = false;",
            "    }",
            "    return os << ']';",
            "}",
            "",
            "template <typename T1, typename T2>",
            "std::ostream& operator<<(std::ostream& os, const std::pair<T1, T2>& p) {",
            "    return os << '(' << p.first << \", \" << p.second << ')';",
            "}",
            "",
            "template <typename T>",
            "void debug_msg(std::string name, T arg) {",
            "    std::cerr << name << \" = \" << arg << std::endl;",
            "}",
            "",
            "template <typename T1, typename... T2>",
            "void debug_msg(std::string names, T1 arg, T2... args) {",
            "    std::cerr << names.substr(0, names.find(',')) << \" = \" << arg << \" | \";",
            "    debug_msg(names.substr(names.find(',') + 2), args...);",
            "}",
            "",
            "#define debug(...) cerr << '(' << __LINE__ << ')' << ' ', debug_msg(#__VA_ARGS__, __VA_ARGS__)",
            "#else",
            "#define debug(...)",
            "#endif",
        }),
    }),
}, {
    key = "cpp",
})

ls.add_snippets("rust", {
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
            "    fn read<T: std::str::FromStr>(&mut self) -> T {",
            "        self.it.next().unwrap().parse::<T>().ok().unwrap()",
            "    }",
            "    fn read_bytes(&mut self) -> Vec<u8> {",
            "        self.it.next().unwrap().bytes().collect()",
            "    }",
            "    fn read_chars(&mut self) -> Vec<char> {",
            "        self.it.next().unwrap().chars().collect()",
            "    }",
            "    fn read_vec<T: std::str::FromStr>(&mut self, len: usize) -> Vec<T> {",
            "        (0..len).map(|_| self.read()).collect()",
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
}, {
    key = "rust",
})

-- in a lua file: search lua-, then c-, then all-snippets.
ls.filetype_extend("lua", { "c" })
-- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
-- ls.filetype_set("cpp", { "c" })

-- Beside defining your own snippets you can also load snippets from "vscode-like" packages
-- that expose snippets in json files, for example <https://github.com/rafamadriz/friendly-snippets>.

require("luasnip.loaders.from_vscode").load({ include = { "python" } }) -- Load only python snippets

-- The directories will have to be structured like eg. <https://github.com/rafamadriz/friendly-snippets> (include
-- a similar `package.json`)
require("luasnip.loaders.from_vscode").load({ paths = { "./my-snippets" } }) -- Load snippets from my-snippets folder

-- You can also use lazy loading so snippets are loaded on-demand, not all at once (may interfere with lazy-loading luasnip itself).
require("luasnip.loaders.from_vscode").lazy_load() -- You can pass { paths = "./my-snippets/"} as well

-- You can also use snippets in snipmate format, for example <https://github.com/honza/vim-snippets>.
-- The usage is similar to vscode.

-- One peculiarity of honza/vim-snippets is that the file containing global
-- snippets is _.snippets, so we need to tell luasnip that the filetype "_"
-- contains global snippets:
ls.filetype_extend("all", { "_" })

require("luasnip.loaders.from_snipmate").load({ include = { "c" } }) -- Load only snippets for c.

-- Load snippets from my-snippets folder
-- The "." refers to the directory where of your `$MYVIMRC` (you can print it
-- out with `:lua print(vim.env.MYVIMRC)`.
-- NOTE: It's not always set! It isn't set for example if you call neovim with
-- the `-u` argument like this: `nvim -u yeet.txt`.
require("luasnip.loaders.from_snipmate").load({ path = { "./my-snippets" } })
-- If path is not specified, luasnip will look for the `snippets` directory in rtp (for custom-snippet probably
-- `~/.config/nvim/snippets`).

require("luasnip.loaders.from_snipmate").lazy_load() -- Lazy loading

-- see DOC.md/LUA SNIPPETS LOADER for some details.
require("luasnip.loaders.from_lua").load({ include = { "c" } })
require("luasnip.loaders.from_lua").lazy_load({ include = { "all", "cpp" } })

-- ls.filetype_set("cpp", { "c" })

