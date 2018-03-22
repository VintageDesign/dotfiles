execute pathogen#infect()

" Found in ~/.vim/bundle/colorschemes/colors
colorscheme monokain

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

" Indentation key maps
" These keymaps cause lots of problems when enabled. The insert keymap causes
" problems with the arrow keys, and the normal keymap causes problems in
" startup. Visual keymap seems to work normally.
" inoremap <C-]> <C-T>
" inoremap <C-[> <C-D>
" vnoremap <C-[> <
" vnoremap <C-]> >
" nnoremap <C-[> <
" nnoremap <C-]> >

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
    \   "fstab": '#',
    \   "desktop": '#',
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
" set cursorcolumn

" Add file pane
autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let g:airline_theme='distinguished'
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#vimtex#enabled = 1

" Linter settings
let g:ale_fixers = {
\   'python': ['pylint'],
\}

let g:ale_completion_enabled = 1
let g:ale_sign_column_always = 1
let g:ale_c_gcc_options = '-std=c11 -Wall -Wextra -Wpedantic'
let g:ale_cpp_gcc_options = '-std=c++17 -Wall -Wextra -Wpedantic'
