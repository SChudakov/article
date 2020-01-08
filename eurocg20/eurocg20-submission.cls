%% eurocg20-submission.cls 
%% Author:     Michael Hoffmann <hoffmann@inf.ethz.ch>
%% Revision: $Rev: 5965 $ from $Date: 2019-02-20 20:22:02 +0100 (Wed, 20. Feb 2019) $
%% wrapper around eurocg20 to obtain a more consistent line numbering
%% we patch/hack some relevant commands and environments and see what happens...

\NeedsTeXFormat{LaTeX2e}[2015/01/01]
\ProvidesClass{eurocg20-submission}[2019/09/09 v0.1 eurocg-wrapper]

%% prefix output by classname
\newcommand{\eurocgtypeout}[1]{\typeout{eurocg20-submission: #1}}%

%% process options
\RequirePackage{ifthen}
\RequirePackage{letltxmacro}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This block is copied over from the original lipics style to include
%% linenumbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage[left,mathlines]{lineno}
\linenumbers
\renewcommand\linenumberfont{\normalfont\tiny\sffamily}
%%%% patch to cope with amsmath
%%%% http://phaseportrait.blogspot.de/2007/08/lineno-and-amsmath-compatibility.html
\newcommand*\patchAmsMathEnvironmentForLineno[1]{%
  \expandafter\let\csname old#1\expandafter\endcsname\csname #1\endcsname
  \expandafter\let\csname oldend#1\expandafter\endcsname\csname end#1\endcsname
  \renewenvironment{#1}%
     {\linenomath\csname old#1\endcsname}%
     {\csname oldend#1\endcsname\endlinenomath}}%
\newcommand*\patchBothAmsMathEnvironmentsForLineno[1]{%
  \patchAmsMathEnvironmentForLineno{#1}%
  \patchAmsMathEnvironmentForLineno{#1*}}%
\AtBeginDocument{%
  \patchBothAmsMathEnvironmentsForLineno{equation}%
  \patchBothAmsMathEnvironmentsForLineno{align}%
  \patchBothAmsMathEnvironmentsForLineno{flalign}%
  \patchBothAmsMathEnvironmentsForLineno{alignat}%
  \patchBothAmsMathEnvironmentsForLineno{gather}%
  \patchBothAmsMathEnvironmentsForLineno{multline}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% End block copied from lipics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% with noalgorithm2e, do not try to fix algorithm2e environments
\newboolean{eurocgnoalgorithm2e}\setboolean{eurocgnoalgorithm2e}{false}
\DeclareOption{noalgorithm2e}{\setboolean{eurocgnoalgorithm2e}{true}}
%% with noalgorithms, do not try to fix algorithms (algorithm/algorithmic) package
\newboolean{eurocgnoalgorithms}\setboolean{eurocgnoalgorithms}{false}
\DeclareOption{noalgorithms}{\setboolean{eurocgnoalgorithms}{true}}
%% with nosubfigcap, do not try to fix subcaptions
\newboolean{eurocgnosubfigcap}\setboolean{eurocgnosubfigcap}{false}
\DeclareOption{nosubfigcap}{\setboolean{eurocgnosubfigcap}{true}}
%% with notab, do not wrap tabular into edtable
\newboolean{eurocgnotab}\setboolean{eurocgnotab}{false}
\DeclareOption{notab}{\setboolean{eurocgnotab}{true}}
%% with notcolorbox, do not try to fix tcolorbox
\newboolean{eurocgnotcolorbox}\setboolean{eurocgnotcolorbox}{false}
\DeclareOption{notcolorbox}{\setboolean{eurocgnotcolorbox}{true}}
%% pass all the rest to LIPIcs
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{eurocg20}}
\ProcessOptions\relax

%% set all line numbering options for algorithm2e
\ifthenelse{\boolean{eurocgnoalgorithm2e}}{%
}{%
  \PassOptionsToPackage{linesnumbered,commentsnumbered,inoutnumbered,titlenumbered}{algorithm2e}
}%
%% set longtable -> edtable option to handle tabular
\ifthenelse{\boolean{eurocgnotab}}{%
}{%
  \PassOptionsToPackage{longtable}{lineno}}%
%% load LIPIcs class
\LoadClass{eurocg20}[2019/09/09]%

%% hide LIPIcs DOI
\def\@DOIPrefix{}

%% \eurocgnl = number line: allows to manually add the current linenumber to a
%% single line if placed at the start of that line
\newsavebox{\eurocgnlbox}%
\newcommand{\eurocgnl}{%
  \sbox{\eurocgnlbox}{\mbox{\linenumberfont\LineNumber\hskip\linenumbersep}}%
  \hspace*{-\wd\eurocgnlbox}\usebox{\eurocgnlbox}\stepcounter{linenumber}%
}

%% used in captions
\newcommand{\eurocglipicsyellowdot}{%
  \kern0.05em{\color[rgb]{0.99,0.78,0.07}\rule{0.73em}{0.73em}}\hspace*{0.67em}}

%% add line numbers to all captions
\DeclareCaptionTextFormat{eurocgnumberitall}{\internallinenumbers #1}
\captionsetup{textformat=eurocgnumberitall}%

%% handle subcaptions (this is a hack, really)
\ifthenelse{\boolean{eurocgnosubfigcap}}{
}{%
  \eurocgtypeout{fix subcaptions}
  \RequirePackage{zref-savepos}
  \newcounter{eurocgstartofnewfloat}\setcounter{eurocgstartofnewfloat}{0}
  \newcounter{eurocglinenumbertmp}\newcounter{eurocglinenumbermax}
  \newcounter{eurocgsubfigcount}\setcounter{eurocgsubfigcount}{0}
  \newcounter{eurocgsubfiglastpos}\setcounter{eurocgsubfiglastpos}{0}
  \let\eurocgsubcaption\subcaption%
  \def\subcaption#1{%
    \stepcounter{eurocgsubfigcount}%
    \zsavepos{\arabic{eurocgsubfigcount}}%
    \ifthenelse{\value{eurocgstartofnewfloat}=1\and\value{eurocgsubfiglastpos}>\zposx{\arabic{eurocgsubfigcount}}}{%
      \eurocgtypeout{add newline in Fig. \thefigure : \thesubfigure}%
      \setcounter{eurocgstartofnewfloat}{0}%
    }{%
    }%
    \setcounter{eurocgsubfiglastpos}{\zposx{\arabic{eurocgsubfigcount}}}%
    \ifthenelse{\value{eurocgstartofnewfloat}=0}{%
      \setcounter{eurocgstartofnewfloat}{1}%
      \setcounter{eurocglinenumbermax}{0}%
      \setcounter{eurocglinenumbertmp}{\value{linenumber}}%
    }{%
      \setcounter{linenumber}{\value{eurocglinenumbertmp}}
    }%
    \eurocgsubcaption{\internallinenumbers #1}%
    \ifthenelse{\value{linenumber} >\value{eurocglinenumbermax}}{%
      \setcounter{eurocglinenumbermax}{\value{linenumber}}}%
    {%
    }%
    \setcounter{linenumber}{\value{eurocglinenumbermax}}%
  }
  \let\eurocgendfigure\endfigure
  \def\endfigure{\setcounter{eurocgstartofnewfloat}{0}\eurocgendfigure}
  \let\eurocgendtable\endtable
  \def\endtable{\setcounter{eurocgstartofnewfloat}{0}\eurocgendtable}

  %% replace subfigure/caption by subcaption
  \renewcommand*\subcaption@minipage[2]{%
    \minipage#1{#2}%
    \renewcommand{\caption}[1]{\subcaption{##1}}\relax}%
}

%% number footnotes by wrapping them into a minipage
\let\eurocgfootnote=\footnote
\newcommand{\eurocgnumberfootnotes}{%
  \gdef\footnote##1{%
    \eurocgfootnote{%
      \begin{minipage}[t]{.978\linewidth}\internallinenumbers\setlength\linenumbersep{2em}
        ##1
      \end{minipage}\vspace{1pt plus .5pt minus .5pt}%
    }%
  }%
}

%% don't number frontmatter 
\let\eurocgrealmaketitle=\maketitle
\renewcommand{\maketitle}{\nolinenumbers\eurocgrealmaketitle\linenumbers}

%% ... not even subject classification, doi, etc.
\let\eurocgabstract=\abstract
\let\eurocgendabstract=\endabstract
\newcounter{eurocglastlinecounter}
\renewenvironment{abstract}{%
  \eurocgabstract%
}{%
  \par\begin{nolinenumbers}
    \eurocgendabstract
    \vskip\baselineskip\noindent
    \textcolor{darkgray}{\fontsize{9.5}{12.5}\sffamily\bfseries Lines\enskip}
    {\ifnum\value{eurocglastlinecounter}>175\color{red}\fi\arabic{eurocglastlinecounter}}
  \end{nolinenumbers}%
  \eurocgnumberfootnotes%
}
%% to list the lines, look where the references start
\AtBeginDocument{%
  \let\eurocgthebibliography=\thebibliography
  \renewcommand{\thebibliography}{%
    \setcounter{eurocglastlinecounter}{\value{linenumber}}%
    \addtocounter{eurocglastlinecounter}{-1}%
    \makeatletter\write\@auxout{\noexpand\setcounter{eurocglastlinecounter}{\theeurocglastlinecounter}}\makeatother%
    \eurocgthebibliography}}

%% wrap tabular into edtable
\ifthenelse{\boolean{eurocgnotab}}{%
}{%
  \eurocgtypeout{fix tabular}
  \let\eurocgtabular\tabular%
  \let\endeurocgtabular\endtabular%
  \renewenvironment{tabular}{\begin{edtable}{eurocgtabular}}{\end{edtable}}%
}

%% fix align etc. "double line number issue"
%% see https://tex.stackexchange.com/questions/436011/linenomath-printing-extra-numbers-on-last-line-of-multline-align-flalign-envir
\newcommand*{\eurocgPatchAmsMathEnvironmentForLineno}[1]{%
  \renewenvironment{#1}%
  {\linenomath\postdisplaypenalty=0\csname old#1\endcsname}%
  {\csname oldend#1\endcsname\endlinenomath}}%
\newcommand*\eurocgpatchBothAmsMathEnvironmentsForLineno[1]{%
  \eurocgPatchAmsMathEnvironmentForLineno{#1}%
  \eurocgPatchAmsMathEnvironmentForLineno{#1*}}%
\AtBeginDocument{%
  \eurocgpatchBothAmsMathEnvironmentsForLineno{align}%
  \eurocgpatchBothAmsMathEnvironmentsForLineno{flalign}%
  \eurocgpatchBothAmsMathEnvironmentsForLineno{alignat}%
  \eurocgpatchBothAmsMathEnvironmentsForLineno{gather}%
  \eurocgpatchBothAmsMathEnvironmentsForLineno{multline}}%

%% number tcolorboxes (just the vanilla ones...)
\ifthenelse{\boolean{eurocgnotcolorbox}}{%
}{%
  \eurocgtypeout{fix tcolorbox}
  \AtBeginDocument{%
    \@ifpackageloaded{tcolorbox}{%
      \LetLtxMacro\eurocgtcolorbox\tcolorbox%
      \LetLtxMacro\endeurocgtcolorbox\endtcolorbox%
      \renewenvironment{tcolorbox}[1][]{%
        \nolinenumbers%
        \eurocgtcolorbox[#1]\internallinenumbers%
        \addtolength{\linenumbersep}{\kvtcb@leftupper}%
        \addtolength{\linenumbersep}{\kvtcb@boxsep}}{%
        \endeurocgtcolorbox%
        \endnolinenumbers}%
    }{%
    }% package tcolorbox loaded 
  }% AtBeginDocument
}% if eurocgtcolorbox

%% fix algorithms
\ifthenelse{\boolean{eurocgnoalgorithms}}{%
}{%
  \newboolean{eurocgalgorithmicorx}\setboolean{eurocgalgorithmicorx}{false}
  \AtBeginDocument{%
    \@ifpackageloaded{algorithmic}{\setboolean{eurocgalgorithmicorx}{true}}{}
    \@ifpackageloaded{algorithmicx}{\setboolean{eurocgalgorithmicorx}{true}}{}
    \ifthenelse{\boolean{eurocgalgorithmicorx}}{%
      \eurocgtypeout{fix algorithmic(x)}%
      \LetLtxMacro\eurocgalgorithmic\algorithmic%
      \LetLtxMacro\endeurocgalgorithmic\endalgorithmic%
      \renewenvironment{algorithmic}[1][]{%
        \eurocgalgorithmic[#1]\internallinenumbers}{%
        \endeurocgalgorithmic}% end of environment algorithmic
    }{%
    }% package algorithmic or algorithmicx loaded 
    \@ifpackageloaded{algorithm}{%
      \eurocgtypeout{fix algorithm}
      \LetLtxMacro\eurocgalgorithms\algorithm%
      \LetLtxMacro\endeurocgalgorithms\endalgorithm%
      \renewenvironment{algorithm}[1][]{%
        \eurocgalgorithms[#1]%
        \LetLtxMacro\eurocgcaption\caption%
        \renewcommand{\caption}[2][]{%
          \eurocgcaption[##1]{\internallinenumbers ##2}}%
      }{\endeurocgalgorithms}% end of environment algorithm
    }{%
    }% package algorithm loaded 
  }% AtBeginDocument
}% if eurocgalgo
    
%% fix algorithm2e
\ifthenelse{\boolean{eurocgnoalgorithm2e}}{%
}{%
  \AtBeginDocument{%
    \@ifpackageloaded{algorithm2e}{%
      \eurocgtypeout{fix algorithm2e}%
      \expandafter\LetLtxMacro\expandafter\eurocgalgorithmte\csname\algocf@envname\endcsname%
      \expandafter\LetLtxMacro\expandafter\endeurocgalgorithmte\csname end\algocf@envname\endcsname%
      \renewenvironment{\algocf@envname}[1][]{%
        \begin{nolinenumbers}%
          \eurocgalgorithmte[#1]%
          \SetAlCapFnt{\small\sffamily}%
          \SetAlCapNameFnt{\small\upshape}%
          \setcounter{AlgoLine}{\value{linenumber}}\addtocounter{AlgoLine}{-1}%
        }{%
          \ifthenelse{\value{linenumber}<\value{AlgoLine}}{%
            \setcounter{linenumber}{\value{AlgoLine}}\stepcounter{linenumber}%
          }{%
          }%
          \endeurocgalgorithmte%
        \end{nolinenumbers}%
      }% end of environment algorithm2e
      %% font for line numbers
      \renewcommand{\relsize}[1]{\normalfont\tiny\sffamily}%
      \newcommand{\eurocgalgocaption}[2]{%
        \begin{minipage}[t]{\hsize}\internallinenumbers%
          \eurocglipicsyellowdot{#1}{~}\AlCapNameSty{\AlCapNameFnt{}#2}%
        \end{minipage}%
      }%
      %% there are two caption types: (1) above the code
      \renewcommand{\algocf@makecaption@ruled}[2]{%
        \global\sbox\algocf@capbox{\eurocgalgocaption{#1}{#2}}%
        \setcounter{AlgoLine}{\value{linenumber}}\addtocounter{AlgoLine}{-1}%
      }% end of algocf@makecaption@ruled
      %% ... and (2) below, which we dress more like the LIPIcs style
      \renewcommand{\algocf@makecaption}[2]{%
        \setcounter{linenumber}{\value{AlgoLine}}\stepcounter{linenumber}%
        \eurocgalgocaption{#1}{#2}%
      }% end of algocf@makecaption
    }{}% package algorithm2e loaded 
  }% AtBeginDocument
}% if eurocgalgo2e
    
\endinput

% Local Variables:
% mode: latex
% End: