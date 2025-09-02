if empty(globpath(&rtp, 'plugin/fzf.vim'))
    echohl WarningMsg | echomsg 'fzf.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_fzf_settings_vim', 0)
    finish
endif

" Key bindings for opening selected files
let g:fzf_action = {
            \ 'ctrl-m': 'edit',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-t': 'tabedit',
            \ 'ctrl-o': has('mac') ? '!open' : '!xdg-open',
            \ }

" Check if Popup/Floating Win is available for FZF or not
if (has('nvim') && exists('*nvim_open_win') && has('nvim-0.4.2')) ||
            \ (exists('*popup_create') && has('patch-8.2.191'))
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7 } }
else
    let g:fzf_layout = {}
endif

if get(g:, 'fzf_inline_info', 1)
    let $FZF_DEFAULT_OPTS .= ' --info=inline-right'
endif

let g:fzf_preview_key = get(g:, 'fzf_preview_key', ';')

let g:fzf_ctags_bin    = get(g:, 'fzf_ctags_bin', 'ctags')
let g:fzf_ctags_ignore = expand(get(g:, 'fzf_ctags_ignore', ''))

let g:fzf_vim = {
            \ 'preview_window': ['hidden,right,50%,<120(up,50%),border-line', g:fzf_preview_key],
            \ 'tags_command':   g:fzf_ctags_bin . (filereadable(g:fzf_ctags_ignore) ? ' --exclude=@' . g:fzf_ctags_ignore : '') . ' -R',
            \ }

let g:fzf_find_tool          = get(g:, 'fzf_find_tool', 'fd')
let g:fzf_find_no_ignore_vcs = get(g:, 'fzf_find_no_ignore_vcs', 0)
let g:fzf_follow_links       = get(g:, 'fzf_follow_links', 1)
let g:fzf_grep_no_ignore_vcs = get(g:, 'fzf_grep_no_ignore_vcs', 0)

let g:fzf_colors = {
            \ 'fg':         ['fg', 'Normal'],
            \ 'bg':         ['bg', 'Normal'],
            \ 'preview-bg': ['bg', 'NormalFloat'],
            \ 'hl':         ['fg', 'Search'],
            \ 'fg+':        ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':        ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':        ['fg', 'Statement'],
            \ 'info':       ['fg', 'PreProc'],
            \ 'border':     ['fg', 'Ignore'],
            \ 'prompt':     ['fg', 'Conditional'],
            \ 'pointer':    ['fg', 'Exception'],
            \ 'marker':     ['fg', 'Keyword'],
            \ 'spinner':    ['fg', 'Label'],
            \ 'header':     ['fg', 'Comment'],
            \ }

augroup FzfSettings
    autocmd!
    autocmd VimEnter * call fzf_settings#command#init()
augroup END

command! ToggleFzfFollowLinks call fzf_settings#files#toggle_follow_links()

" Files command with preview window
command! -bang -nargs=? -complete=dir Files  call fzf_settings#files#run(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir AFiles call fzf_settings#files#all(<q-args>, <bang>0)

command! -bang -nargs=* Rg    call fzf_settings#grep#rg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* FRg   call fzf_settings#grep#frg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* RRg   call fzf_settings#grep#rg_raw(<q-args>, <bang>0)
command! -bang -nargs=* RgRaw call fzf_settings#grep#rg_raw(<q-args>, <bang>0)
command! -bang -nargs=* RG    call fzf_settings#grep#rg2(<q-args>, <bang>0)
command! -bang -nargs=* FRG   call fzf_settings#grep#frg2(<q-args>, <bang>0)

" Extra commands
command! -bang          Mru          call fzf_settings#mru#run(<bang>0)
command! -bang          MruCwd       call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang          MruInCwd     call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang -nargs=? BOutline     call fzf_settings#boutline#run(<q-args>, <bang>0)
command! -bang          Quickfix     call fzf_settings#quickfix#quickfix(<bang>0)
command! -bang          LocationList call fzf_settings#quickfix#loclist(<bang>0)
command! -bang          Registers    call fzf_settings#registers#run(<bang>0)

let g:loaded_fzf_settings_vim = 1
