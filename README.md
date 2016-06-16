# style-check.rb

The code described in this README parses latex-formatted text in search of forbidden phrases and prints error messages formatted as if from a compiler.

# Why does this code exist?

This code is a weapon against collaborators who would dilute your writing with ambiguous or verbose prose. It was designed to ensure that collaborative papers appear in a consistent style: mine.

I think of all activities as coding. My presentations use python scripts, not powerpoint. My writing and research posters use latex and emacs, not word or publisher. When I write code, I try to be creative and sloppy, relying on tools to identify most of my mistakes. (For example, gcc issues warnings, splint can verify some memory processes, and custom scripts can identify simple portability problems.) When writing text, I had no such tools.

The style checker is one such tool. When I notice a mistake that can be identified by a regular expression, I add a forbidden expression to the style checker's ruleset. Then, when I build my latex-formatted paper, I run the style checker to seek out such phrases.

It has saved me from submitting gramatically-sloppy last-minute edits.

Like the warnings printed by a compiler, errors from the style checker should not be taken literally. Use your own judgement to correct sentences: make them shorter, more specific, and more varied. I cannot advise you to rely on this tool in the way I do; my approach to writing is not necessarily a good one for anyone.

# How does it work?

The style checker is a ruby script that seeks out files in directories /etc/style-check.d or ~/.style-check.d, or files named ~/.style-censor or ./style-censor. Each file is a list of expressions in one of four types, annotated with a justification. See the existing files for examples.

## Type 1: Syntax

Syntax expressions are matched exactly. They are case-sensitive. Any regular expression will do. As a hint, "\b" will match some non-word character, like a space or newline.

<pre class="example">[ ],       <span class="examplecomment">% syntax whitespace before comma seems wrong.</span>
''[\.,]    <span class="examplecomment">% syntax end quotes go outside punctuation like . and ,</span> 
[ ]-[ ]    <span class="examplecomment">% syntax a hyphen surrounded by space should probably be an emdash '---'</span>
</pre>

## Type 2: Capitalize

Capitalize expressions match whole words, and are case-sensitive. Such expressions are designed to help maintain uniformity of capitalization of product and project names, like PlanetLab, Scriptroute, CoDeeN, iPod, etc. They are transparently wrapped with "\b"s to ensure that only whole words are matched.

<pre class="example">Planetlab   <span class="examplecomment">% capitalize PlanetLab</span>
planetlab   <span class="examplecomment">% capitalize PlanetLab</span>
ccdf        <span class="examplecomment">% capitalize</span>
cisco       <span class="examplecomment">% capitalize the company name</span>
internet    <span class="examplecomment">% capitalize unless talking about an internet other than the Internet</span>
ttl         <span class="examplecomment">% capitalize</span>
</pre>

## Type 3: Phrase

Phrases match longer phrases such as "the foreseeable future" or ["at the end of the day"](http://www.plainenglish.co.uk/pressrelease.html). As with capitalize expressions, they are transparently wrapped with "\b"s, but are not case sensitive. Some phrases that should be forbidden include double words.

<pre class="example">[^r][^c][^h] impact           <span class="examplecomment">% phrase "effect", "result", though nsf likes "research impact"</span>
absolutely essential          <span class="examplecomment">% phrase essential</span>
few in number                 <span class="examplecomment">% phrase few</span>
the the                       <span class="examplecomment">% phrase apparent double word.</span>
(quite|more|very|most) unique <span class="examplecomment">% phrase unique is.</span>
a large number of             <span class="examplecomment">% phrase you mean "many"</span>
the way in which              <span class="examplecomment">% phrase should be "how" or ""</span> 
live in a vacuum              <span class="examplecomment">% phrase a tired metaphor that makes me want to vomit.</span> 
</pre>

## Type 4: Spelling

Spelling expressions are internally handled just like phrases. These are useful for common misspellings or typo's. Perhaps you habitually misspell lose as loose and would prefer to have a checker complain. I habitually misspell measurment, secrurity, and experiements.

<pre class="example">experiements <span class="examplecomment">% spelling</span>
measurment   <span class="examplecomment">% spelling</span>
secrurity    <span class="examplecomment">% spelling</span>
taht         <span class="examplecomment">% spelling</span>
teh          <span class="examplecomment">% spelling</span>
privledge    <span class="examplecomment">% spelling "privilege" I misspell it every way possible.</span>
privlege     <span class="examplecomment">% spelling "privilege" I misspell it every way possible.</span>
priviledge   <span class="examplecomment">% spelling "privilege" I misspell it every way possible.</span>
queueing     <span class="examplecomment">% spelling I'd love to spell it this way, but spellchecker whines.</span>
</pre>

## Type -1: Ignored Commands

Ignore the parameter to this command. If only spell checkers were this cool. The standard ignored commands are \begin, \end, \url, \cite, \ref, \label, and a few others. You can extend this in ./censor-dict with a personal dictionary that might include, for example \todo or \hostname. The internal implementation of ignored commands is to "replace" them with ~ (the non-breaking space character) before the rest of the rules are checked, so it is possible that other rules may need to take this into account.

<pre class="example">todo      <span class="examplecomment">% ignoredcommand</span>
texttt    <span class="examplecomment">% ignoredcommand</span>
</pre>

## Built-in checking

In addition to configurable rules, the style checker also seeks out common errors within the LaTeX source itself:

*   an unescaped percent-sign directly following a number is frequently an error.
*   a \cite{} tag should precede (not follow) a period.
*   a \cite{} tag should not be used obviously as a noun in the middle of a sentence.
*   paragraphs should end with the end of a sentence.

Comments using \begin{comment} and \end{comment} from comment.sty are skipped.

Math mode between unescaped $'s is skipped.

For more detail, read the ruby code. It's shorter than this file.

# How do I use it?

From the style-check-(version) directory, run
<tt>sudo make install</tt>
to install as the superuser. As an alternative,
<tt>make user-install</tt>
will put the ruleset in your home-directory, but putting the style-check.rb script in your path is up to you.

To run the script,
<tt>style-check.rb *.tex</tt>

Or, if you'd like a little justification with your scolding,
<tt>style-check.rb -v *.tex</tt>

# Limitations

This is not a proof-reader, editor, spelling checker, or grammar checker. It can catch only some simple, common, frustrating mistakes. It is not a substitute for reading what I've listed below. It is intended only for LaTeX files.

This code will not teach you to use "that" and "which" properly. It will not teach you to hyphenate. It may be used for evil. You may think my rules are stupid.

There are many bugs in the code; it is not guaranteed that the style checker will find all forbidden phrases. It may become confused by nested environments.

# Attitude

Don't ask me to add a feature. Send me a patch.

Don't complain that it's written in Ruby. My language kicks your language's ass.

Don't complain about the ruleset. Invent a mechanism to override ones you don't care for.

# Further Reading

This section is split into two categories -- entertainment for reading that is light and fun and should help you think about writing better, and reference that may help answer harder questions.

## Entertainment

The Elements of Style, by Strunk and White
[http://www.bartleby.com/141/](http://www.bartleby.com/141/)

Woe is I: The Grammarphobe's Guide to Better English in Plain English, by Patricia T. O'Conner.

Lake Superior State University Banished Words List
[http://www.lssu.edu/banished/](http://www.lssu.edu/banished/)

Usage in The American Heritage Dictionary
[http://www.bartleby.com/61/7.html](http://www.bartleby.com/61/7.html)

alt.usage.english FAQ
[http://alt-usage-english.org/fast_faq.shtml](http://alt-usage-english.org/fast_faq.shtml)

How To Write A Dissertation, by Doug Comer
[http://www.cs.purdue.edu/homes/dec/essay.dissertation.html](http://www.cs.purdue.edu/homes/dec/essay.dissertation.html)

Plain English Campaign
[http://www.plainenglish.co.uk/](http://www.plainenglish.co.uk/)

Thesis Errors
[http://core.ecu.edu/psyc/wuenschk/therr.htm](http://core.ecu.edu/psyc/wuenschk/therr.htm)

How to Avoid Colloquial (Informal) Writing
[http://www.wikihow.com/Avoid-Colloquial-%28Informal%29-Writing](http://www.wikihow.com/Avoid-Colloquial-%28Informal%29-Writing)

Henning Schulzrinne's Notes 
[http://www.cs.columbia.edu/~hgs/etc/writing-style.html](http://www.cs.columbia.edu/~hgs/etc/writing-style.html)

## Reading that takes work (and reference)

Rules for Writers, by Diana Hacker.

The New Oxford Guide to Writing, by Thomas S. Kane.

Line by Line: How to Edit Your Own Writing, by Claire Cook.

## Related Code

Michael Haardt wrote GNU [diction](http://www.gnu.org/software/diction/diction.html), which is similar in that it finds and complains about bad phrases, but different in that it also notes questionable phrases (such as any use of "affect") and does not expect to check LaTeX source. Style-check focuses on forbidden phrases and common typographic errors in LaTeX code.

## To install

<pre class="example">
gem install style-check 
</pre>
[http://www.cs.umd.edu/~nspring/software/style-check-current.tar.gz](http://www.cs.umd.edu/~nspring/software/style-check-current.tar.gz)

# Thanks

Kurt Partridge for encouraging me to release this thing.

Vibha Sazawal for reminding me often that there is more to writing than style.

Rich Wolski for introducing me to Strunk and White, the gateway drug.

Jacob Martin reported the first bug, packaged style-check for [gentoo](http://www.gentoo-portage.com/dev-tex/style-check), and contributed a ruleset based on [Day and Gastel, "How to Write and Publish a Scientific Paper"](http://www.amazon.com/How-Write-Publish-Scientific-Paper/dp/0313330271).

Indika Meedeniya noticed a few more bugs and suggested compatibility with gedit.

Rudolf Mühlbauer suggested:

> I use it in conjunction with vim [:make | copen]:
> 
> <pre>~/.vim/ftplugin/tex.vim:
> set makeprg=~/opt/style-check-0.14/style-check.rb\ -v\ %
> </pre>

Vinícius Vielmo Cogo provided an html output scheme.

* * *

<address>[Neil Spring](mailto:nspring@cs.umd.edu)</address>
