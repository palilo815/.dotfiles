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
      "#include <bits/stdc++.h>",
      "",
      "auto main() -> int {",
      "    using namespace std;",
      "    cin.tie(nullptr)->sync_with_stdio(false);",
      "\t",
    },
    i(1),
    t { "", "}" },
  }),
  s("parametric", {
    t {
      "auto parametric = [&]<typename T>(T lo, T hi) {",
      "    auto f = [&](T mid) -> bool {",
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
        "// first true",
        "while (lo != hi) {",
        "    auto mid = lo + (hi - lo) / 2;",
        "    f(mid) ? hi = mid : lo = mid + 1;",
        "}",
      },
      t {
        "// last true",
        "while (lo != hi) {",
        "    auto mid = hi - (hi - lo) / 2;",
        "    f(mid) ? lo = mid : hi = mid - 1;",
        "}",
      },
    }),
    t {
      "",
      "    return lo;",
      "};",
    },
  }),
  s("y_combinator", {
    t {
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
    },
  }),
  s("dfs_ordering", {
    t {
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
    },
  }),
  s("chminmax", {
    t {
      "template <class T>",
      "bool chmin(T& _old, T _new) { return _old > _new && (_old = _new, true); }",
      "template <class T>",
      "bool chmax(T& _old, T _new) { return _old < _new && (_old = _new, true); }",
    },
  }),
  s("next_bitset", {
    t {
      "auto next_bitset = [](const auto x) {",
      "    const auto c {x & -x};",
      "    const auto r {x + c};",
      "    return (((x ^ r) >> 2) / c) | r;",
      "};",
    },
  }),
  s("gp_hash", {
    t {
      "#include <bits/extc++.h>",
      "",
      "// http://xorshift.di.unimi.it/splitmix64.c",
      "struct splitmix64_hash {",
      "    static auto splitmix64(size_t x) {",
      "        x += 0x9e3779b97f4a7c15;",
      "        x = (x ^ (x >> 30)) * 0xbf58476d1ce4e5b9;",
      "        x = (x ^ (x >> 27)) * 0x94d049bb133111eb;",
      "        return x ^ (x >> 31);",
      "    }",
      "",
      "    auto operator()(uint64_t x) const {",
      "        static const size_t FIXED_RANDOM = std::chrono::steady_clock::now().time_since_epoch().count();",
      "        return splitmix64(x + FIXED_RANDOM);",
      "    }",
      "};",
      "",
      "template <typename K, typename V>",
      "using hash_map = __gnu_pbds::gp_hash_table<K, V, splitmix64_hash>;",
      "",
      "template <typename K>",
      "using hash_set = hash_map<K, __gnu_pbds::null_type>;",
    },
  }),
  s("MOVE", {
    t "constexpr std::array<std::pair<int, int>, 4> MOVE {{{-1, 0}, {0, -1}, {0, 1}, {1, 0}}};",
  }),
  s("DEBUG", {
    t {
      "#ifdef palilo",
      "template <typename C, typename T = typename std::enable_if<!std::is_same<C, std::string>::value, typename C::value_type>::type>",
      "std::ostream& operator<<(std::ostream& os, const C& container) {",
      "    os << '[';",
      "    bool first = true;",
      "    for (const auto& x : container) {",
      '        if (!first) os << ", ";',
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
      '    std::cerr << name << " = " << arg << std::endl;',
      "}",
      "",
      "template <typename T1, typename... T2>",
      "void debug_msg(std::string names, T1 arg, T2... args) {",
      '    std::cerr << names.substr(0, names.find(\',\')) << " = " << arg << " | ";',
      "    debug_msg(names.substr(names.find(',') + 2), args...);",
      "}",
      "",
      "#define debug(...) cerr << '(' << __LINE__ << ')' << ' ', debug_msg(#__VA_ARGS__, __VA_ARGS__)",
      "#else",
      "#define debug(...)",
      "#endif",
    },
  }),
}
