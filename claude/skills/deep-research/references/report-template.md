# ディープリサーチ レポートテンプレート

Phase 5 で生成するレポートの雛形。`{{ }}` を埋めて使う。インライン引用はすべて
`<a href="URL" target="_blank">タイトル</a>` のHTMLアンカーで書く。

```markdown
# {{調査テーマ}}

*調査日: YYYY-MM-DD ／ 検索クエリ数: N ／ 参照ソース数: M*

## エグゼクティブサマリー

- {{結論1}}
- {{結論2}}
- {{結論3}}

## 目次

1. [{{セクション1}}](#section-1)
2. [{{セクション2}}](#section-2)
3. 結論
4. Sources

## {{セクション1（sub-question 1）}} {#section-1}

{{本文。主張ごとに根拠を引用する}}<a href="https://example.com/a" target="_blank">出典A</a>。

複数ソースで裏が取れた点と、ソース間で食い違った点を明示する。
矛盾がある場合は両論併記:

- 立場X: {{要旨}}<a href="https://example.com/x" target="_blank">出典X</a>
- 立場Y: {{要旨}}<a href="https://example.com/y" target="_blank">出典Y</a>

## {{セクション2（sub-question 2）}} {#section-2}

{{本文}}

## 結論

- **確度の高い知見:** {{...}}
- **未解決/要追跡の論点:** {{...}}
- **推奨アクション（あれば）:** {{...}}

## Sources

1. <a href="https://example.com/a" target="_blank">出典Aのタイトル</a>
2. <a href="https://example.com/x" target="_blank">出典Xのタイトル</a>
3. <a href="https://example.com/y" target="_blank">出典Yのタイトル</a>
```

## 記入のポイント

- エグゼクティブサマリーは結論の先出し。読者がここだけで要旨を掴めること。
- 事実／専門家見解／推測は文中で語の格を変えて区別する（「〜である」「〜と指摘する」「〜の可能性がある」）。
- Sources は本文の引用と1対1で対応させる。本文で引用していないURLを Sources に混ぜない。
