execute pathogen#infect()

" Found in ~/.vim/bundle/colorschemes/colors
colorscheme wargrey

" Set default encoding to UTF-8
set enc=utf-8

" Set autowrite for use with :make
set autowrite

" Number of visual spaces per TAB
set tabstop=4
" Number of spaces in tab when editing
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
set backspace=indent,eol,start

"Use terminal title
set title
set titlestring=%F

" Show line numbers
set number
" Keep the cursor 6 lines from bottom of screen.
set scrolloff=6
" Toggle paste mode with f3
set pastetoggle=<F3>

" Allow fuzzy menu
set wildmenu
" Redraw screen lazily
set lazyredraw
"Matching brackets highlighted
set showmatch
" Highlight as characters are entered
set incsearch
" Must be turned off manually
set hlsearch
" Turn off search highlighting with enter
nnoremap <CR> :nohl<CR><CR>

" Use ctrl+[jk] to move lines up and down in normal, insert, and visual mode.
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" enable code folding
set foldenable
set foldlevelstart=15
set foldnestmax=10
set foldmethod=indent

nnoremap <space> za "Space za folds, unfolds

" Visual movement
nnoremap j gj
nnoremap k gk

" Move to beginning and end of line
nnoremap B ^
nnoremap E $
" Unset $ and ^ to deter vim professionals from using my device.
nnoremap $ <nop>
nnoremap ^ <nop>

let s:comment_map = {
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \ }

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " "
            " Uncomment the line
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else
            if getline('.') =~ "^\\s*" . comment_leader
                " Uncomment the line
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                " Comment the line
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
endfunction

" Comments a single line, use visual mode and gc to comment blocks
nnoremap <C-_> :call ToggleComment()<CR>
vnoremap <C-_> :call ToggleComment()<CR>

" Highlight current line
set cursorline
" Highlight current column
set cursorcolumn

" Add file pane
autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Syntastic settings
hi statusline ctermfg=White ctermbg=DarkGrey

" Formats the statusline
set statusline=%f       " file name
" set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
" set statusline+=%{&ff}] "file format
set statusline+=\ %y      "filetype
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

set statusline+=\ %=                        " align left
set statusline+=Line:%l/%L[%p%%]            " line X of Y [percent of file]
set statusline+=\ Col:%c                    " current column
set statusline+=\ Buf:%n                    " Buffer number
set statusline+=\ [%b][0x%B]\               " ASCII and byte code under cursor

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Specify linters
let g:syntastic_asm_checkers=['gcc']
let g:syntastic_tex_checkers=['chktex']
let g:syntastic_py_checkers=['pylint']

" Specify linter options
let g:syntastic_asm_dialect='intel'

