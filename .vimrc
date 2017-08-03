execute pathogen#infect()

colorscheme badwolf " saved in ~/.vim/colors/*.vim

syntax enable
set tabstop=4 " Number of visual spaces per TAB
set softtabstop=0 "Number of spaces in tab when editing
set expandtab
set shiftwidth=4
set smarttab

set number "line numbers
set cursorline

set wildmenu
set lazyredraw
set showmatch "Matching brackets highlighted
set incsearch
set hlsearch "Must be turned off manually

" turn off search highlight `,<space>`
nnoremap <leader><space> :nohlsearch<CR>

set foldenable "enable folding
set foldlevelstart=15
set foldnestmax=10 "max fold level

nnoremap <space> za "Space za folds, unfolds
set foldmethod=indent

nnoremap j gj
nnoremap k gk

" Cursor
set cursorline
"set cursorcolumn
"hi Cursor guifg=Green guibg=Black
"hi CursorLine guibg=#333333
"hi CursorColumn guibg=#333333

autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

