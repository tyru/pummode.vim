" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" Functions {{{
func! pummode#load() "{{{
    " Dummy function to load this script
    " from your .vimrc.
endfunc "}}}

func! pummode#map(modes, options, remap_p, lhs, rhs) "{{{
    for m in split(a:modes, '\zs')
        if !s:is_available_mode(m)
            echohl WarningMsg
            echomsg printf("mode '%s' is not supported.", m)
            echohl None
            continue
        endif

        call s:do_map(m, a:options, a:remap_p, a:lhs, a:rhs)
    endfor
endfunc "}}}


" Utilities
func! s:stringf(fmt, ...) "{{{
    return call('printf', [a:fmt] + map(copy(a:000), 'string(v:val)'))
endfunc "}}}

func! s:is_available_mode(mode) "{{{
    return a:mode =~# '^[il]$'
endfunc "}}}
func! s:do_map(mode, options, remap_p, lhs, rhs) "{{{

    " map <expr> lhs pumvisible() ? "rhs-keycode" : "lhs-keycode"

    execute
    \   printf('%s%smap', a:mode, (a:remap_p ? '' : 'nore'))
    \   '<expr>' . s:replace_options(a:options)
    \   a:lhs
    \   s:stringf('pumvisible() ? %s : %s',
    \       s:eval_key(a:rhs),
    \       s:eval_key(a:lhs))
endfunc "}}}
func! s:replace_options(options) "{{{
    let table = {
    \   'b' : '<buffer>',
    \   's' : '<silent>',
    \   'u' : '<unique>',
    \}
    let uniqued = split(a:options, '\zs')
    return join(map(uniqued, 'get(opts, v:val, "")'), '')
endfunc "}}}

" For s:eval_key().
func! s:split_key(key) "{{{
    let head = matchstr(a:key, '^[^<]\+')
    return [head, strpart(a:key, strlen(head))]
endfunc "}}}
" For s:eval_key().
func! s:split_special_key(key) "{{{
    let head = matchstr(a:key, '^<[^>]\+>')
    return [head, strpart(a:key, strlen(head))]
endfunc "}}}
func! s:eval_key(key) "{{{
    let key = a:key
    let evaled = ''
    while 1
        let [left, key] = s:split_key(key)
        let evaled .= left
        if key == ''
            return evaled
        elseif key[0] ==# '<' && key[1] ==# '>'
            " '<>'
            let evaled .= strpart(key, 0, 2)
            let key = strpart(key, 2)
        elseif key[0] ==# '<' && key =~# '^<[^>]*$'
            " No '>'
            return evaled . key
        elseif tolower(key) =~# '^<lt>'
            " '<lt>' -> '<'
            let evaled .= '<'
            let key = strpart(key, strlen('<lt>'))
        elseif key[0] ==# '<'
            " Special key.
            let [sp_key, key] = s:split_special_key(key)
            let evaled .= eval(printf('"\%s"', sp_key))
        else
            throw 'internal error'
        endif
    endwhile
endfunc "}}}
" }}}

" Commands {{{
" TODO Comand macros
" }}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
