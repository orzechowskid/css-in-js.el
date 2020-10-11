# css-in-js.el
Emacs minor mode to enable a better development experience for (some) CSS-in-JS.  If your webapp uses:

- [styled-components](https://styled-components.com/)
- [@emotion/styled](https://emotion.sh/docs/styled)
- [styled-jsx](https://github.com/vercel/styled-jsx)

then this might be of use to you.

![](https://repository-images.githubusercontent.com/303042672/e47cad80-0bbe-11eb-8ed2-bb0f150617c5)

_above: `typescript-mode`, styled-components, and `company-mode` with `company-quickhelp-mode`_

## Installation

0. Dependencies: make sure you have `mmm-mode` and `scss-mode` installed already.  They're both available in MELPA and probably elsewhere too.
1. Install:  download this package and place it inside a directory on your `load-path`
2. Require:  `(require 'css-in-js)`
3. Enable: `(css-in-js-mode t)`

## Configuration

`css-in-js-mode` itself has nothing to configure, but it uses `css-indent-offset` during indentation so be sure to set that to an acceptable value.

You might also be interested in playing around with `mmm-submode-decoration-sublevel`.

## Bugs?

plenty.  indentation is kinda janky right now, there are probably some enhancements to be made around LSP, and it doesn't support a whole bunch of popular css-in-js libraries.  I've also only done minimal testing with `web-mode` and `js-mode`.  PRs welcome for any and all bugs and feature-requests!
