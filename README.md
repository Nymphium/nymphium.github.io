# nymphium.github.io

[はてブ](http://nymphium.hateblo.jp/)からの移行

2015/04/06 Jekyll 3にしました｡

# syntax extensions
## import

### `@importmd(path/to/md)`

```markdown
@importmd(path/to/md)
<!-- path/to/md
hello import
-->
```

converts to

```markdown
hello import
```

```markdown
```

### `@importlisting(path/to/code)`, `@importlisting[caption](path/to/code)`, `@importlisting(path/to/code filetype)`

```markdown
@importlsting[cap](/path/to/code ft)
<!-- path/to/code
puts "hello"
-->
```

converts to

``````markdown
```ft:cap
puts "hello"
```
``````

## ref

```markdown
# a
## a.b
[label:foo]you can refer here

refer [ref:foo]

refer <foo>[ref:foo]

refer [fnref: 1]

---
[^1]: footnote
```

converts to

```markdown
<label id="foo"></label>you can refer here

refer <a href="#foo">(a.b)</a>

refer <a href="#foo">foo</a>

refer [<a href="#fn1">1</a>]
```

## liquid plugin
### twicardify
```markdown
{% twicard alt url %}

or

{% twicard "alt" url %}
```

### GitHub repository
```markdown
{% gh_repo usr/repo %}
```

### twitter id
```markdown
{% twid id %}
```

# LICENSE
[MIT](http://opensource.org/licenses/MIT)

