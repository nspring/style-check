#!/usr/bin/ruby

# a simple script to check against a ruleset of "forbidden"
# phrases and spellings.  it is intended as a quick check
# against verbose phrases, overused expressions, incorrect
# spellings, and inconsistent capitalization or hypenation.

# complexity in this script arised from handling basic tex
# comments, ignoring fragments of tex that are allowed to 
# violate style (such as the bibtex tag inside \cite{})

# the dictionary of censored phrases is a compound of
# ~/.style-censor, ./censor-dict (for historical reasons),
# and /etc/style-censor for particularly egregious
# violations (such as spelling errors and common double-word
# problems).

# this script is not intended to substitute for a spell
# checker, a grammar checker, or a proof-reader.  And the 
# phrases listed aren't necessarily forbidden; they may 
# simply be discouraged.  Those that are particularly weak
# should be annotated with "weak" leading the description.

# Bugs 

# - misspelled words may not be recognized if capitalized.
# This is a consequence of the script's goal of watching for
# uniform upper- and lower- case project names and such.  

# - expressions with % in them won't be matched; the %
# character is reserved for explanatory text.

if(ARGV[0] == "-v") then
  ARGV.shift
  $VERBOSE = true
end

$exit_status = 0

PctCensored_phrases = Hash.new  # before stripping comments
PreCensored_phrases = Hash.new  # before stripping cites
Censored_phrases = Hash.new     # the rest.

( Dir.glob("/etc/style-censor.d/*") + 
   Dir.glob(ENV["HOME"] + "/.style-censor.d/*") +
   [ ENV["HOME"] + "/.style-censor", "./censor-dict", 
     "/etc/style-censor", "./style-censor" ]).map { |rulefilename| 
  if ( Kernel.test(?e, rulefilename) ) then
    File.open(rulefilename).each_with_index { |phr,lnnum_minus_one|
      #if ( ! phr.scan(~ /^# / ) then 
      expression, reason = phr.split(/\s*%\s*/) 
      if( reason ) then 
        Censored_phrases[ 
          case reason.split(/\s+/)[0]
          when 'syntax'
            Regexp.new(expression.chomp) 
          when 'capitalize'
            Regexp.new('\b' + expression.chomp + '\b' ) 
          when 'phrase' 
            Regexp.new('\b' + expression.chomp + '\b', Regexp::IGNORECASE ) 
          when 'spelling' 
            Regexp.new('\b' + expression.chomp + '\b', Regexp::IGNORECASE ) 
          else
            puts "warning: no class specified for %s at %s:%d" % [ expression, rulefilename, lnnum_minus_one + 1 ]
            Regexp.new('\b' + expression.chomp + '\b' ) 
          end
        ] = ( reason or "" ) + "  (matched '" + expression.chomp + 
                              "' in %s:%d)" % [ rulefilename, lnnum_minus_one + 1 ]
        # end
      end
    }
    else 
    []
  end
}

PreCensored_phrases[ 
  Regexp.new(/\.\\cite/) ] = "~\cite{} should precede the period."
PreCensored_phrases[ 
  Regexp.new(/\b(from|in|and)~\\cite/) ] = "don't cite in the sentence as from or in [x]."
PreCensored_phrases[ 
  Regexp.new(/[^\.\n]\n\n/) ] = "paragraphs should end with a sentence end"

PctCensored_phrases[ 
  Regexp.new(/[0-9]%/) ] = "a percent following a number is rarely an intended comment."

if(Censored_phrases.length == 0) then
  puts "no style-censor phrases found.  write some in ./style-censor."
  exit 1
end

De_comment = Regexp.new('(([^\\\\]%.*)|(^%.*))$')
De_command = Regexp.new('(~?\\\\(ref|href|cite|nocite|cline|includegraphics|begin|end|label)(\[[^\]]*\])?\{[^{}]*\})')

def do_cns(line, file, linenum, phra_hash)
  m = nil
  r = nil # so we can keep it as a side-effect of the detect call
  if(phra_hash.keys.detect { |r| m = r.match(line) } ) then
    puts "%s:%d: %s (%s)" % [ file, linenum, line.chomp, m ]
    if($VERBOSE && phra_hash[r]) then
      puts "  " + phra_hash[r]
      phra_hash[r] = nil # don't print the reason more than once
    end
    $exit_status = 1 if(!phra_hash[r] =~ /\?\s*$/) 
  end
end
 
Input_files = ARGV
Input_files.each { |f|
  in_multiline_comment = 0
  # load the file, contents, but drop comments and other
  # hidden tex command pieces
  lines = File.open(f).readlines
  lines.each_with_index { |ln,i|
    do_cns( ln, f, i+1, PctCensored_phrases )
    ln.sub!(De_comment, '')
    if( ln =~ /\\begin\{comment\}/ ) then
      in_multiline_comment+=1
    elsif( ln =~ /\\end\{comment\}/ ) then
      in_multiline_comment-=1
    end
    if(in_multiline_comment == 0)  then
      do_cns( ln, f, i+1, PreCensored_phrases )
      ln.gsub!(De_command, '')
      do_cns( ln, f, i+1, Censored_phrases )
      
      # now try to make sure that paragraphs end with sentence
      # ending punctuation, such as a period, exclamation mark,
      # question mark, or perhaps a command-ending brace.
      if(lines.length > i+3) then
        checkstring = lines[i..(i+1)].map { |ln| 
          ln.sub!(De_comment, '');   
          ln.sub!(/\\[a-z]+=[0-9]+/, '');  # tex variable assignment; I format each on its own line.
          ln }.join 
        #if(checkstring =~ /SIGCOMM/) then
          #puts "%s:%d: argh: %s" % [ f, i, checkstring.gsub(/\n/, '\n') ];
        #end
        if(checkstring =~ /[a-z0-9][^\.\!\?\n}]\n\n/) then
          puts "%s:%d: apparent bad paragraph break: %s" % [ 
            f, i+1, checkstring.gsub(/\n/, '\n') ];
        end
      end
    end
  }
}
    
