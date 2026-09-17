# SSH 先の tmux / herdr が有効化した端末モードを、プロンプト表示のたびに解除する。
# スリープ等で SSH が異常切断すると解除シーケンスが届かず、手元の端末に
# マウス報告（0;110;31M など）や CSI u 形式のキー（97;5u など）が入力されてしまうため。
#   ?1000/?1002/?1003/?1006: マウス報告  ?1004: フォーカス報告
#   <99u: kitty keyboard protocol のフラグを全て pop  >4;0m: modifyOtherKeys 解除
#   ?25h: 非表示のまま残ったカーソルを再表示
# ?2004（bracketed paste）は zsh 自身が使うので触らない。
# 多重化ソフトの内側でも登録する（ペイン内から SSH して切断した場合もペインにモードが残るため）。
if [[ "$TERM" != "dumb" ]]; then
  _reset_terminal_modes() {
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[<99u\e[>4;0m\e[?25h'
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _reset_terminal_modes
fi
