local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
  return
end
local s = ls.snippet
local t = ls.text_node

ls.add_snippets('all', {
  s('initcpp', t {
    "#include <bits/stdc++.h>",
    "",
    "using namespace std;",
    "",
    "#define ll long long",
    "",
    "void solve() {",
    "",
    "}",
    "",
    "int main() {",
    "  ios_base::sync_with_stdio(0);",
    "  cin.tie(nullptr);",
    "  int T;",
    "  cin >> T;",
    "  while(T--) solve();",
    "}"
  })
})

ls.add_snippets('all', {
  s('init_ordered_set', t {
    "#include <ext/pb_ds/assoc_container.hpp>",
    "#include <ext/pb_ds/tree_policy.hpp>",
    "typedef __gnu_pbds::tree<int, __gnu_pbds::null_type, less<int>, __gnu_pbds::rb_tree_tag, __gnu_pbds::tree_order_statistics_node_update> ordered_set;"
  })
})
