/*
 * 09/11/2008
 *
 * RubyTokenMaker.java - Scanner for Ruby
 * 
 * This library is distributed under a modified BSD license.  See the included
 * LICENSE file for details.
 */
package org.fife.ui.rsyntaxtextarea.modes;

import java.io.*;
import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.*;


/**
 * Scanner for Ruby.<p>
 *
 * This implementation was created using
 * <a href="https://www.jflex.de/">JFlex</a> 1.4.1; however, the generated file
 * was modified for performance.  Memory allocation needs to be almost
 * completely removed to be competitive with the handwritten lexers (subclasses
 * of <code>AbstractTokenMaker</code>), so this class has been modified so that
 * Strings are never allocated (via yytext()), and the scanner never has to
 * worry about refilling its buffer (needlessly copying chars around).
 * We can achieve this because RText always scans exactly 1 line of tokens at a
 * time, and hands the scanner this line as an array of characters (a Segment
 * really).  Since tokens contain pointers to char arrays instead of Strings
 * holding their contents, there is no need for allocating new memory for
 * Strings.<p>
 *
 * The actual algorithm generated for scanning has, of course, not been
 * modified.<p>
 *
 * If you wish to regenerate this file yourself, keep in mind the following:
 * <ul>
 *   <li>The generated <code>RubyTokenMaker.java</code> file will contain two
 *       definitions of both <code>zzRefill</code> and <code>yyreset</code>.
 *       You should hand-delete the second of each definition (the ones
 *       generated by the lexer), as these generated methods modify the input
 *       buffer, which we'll never have to do.</li>
 *   <li>You should also change the declaration/definition of zzBuffer to NOT
 *       be initialized.  This is a needless memory allocation for us since we
 *       will be pointing the array somewhere else anyway.</li>
 *   <li>You should NOT call <code>yylex()</code> on the generated scanner
 *       directly; rather, you should use <code>getTokenList</code> as you would
 *       with any other <code>TokenMaker</code> instance.</li>
 * </ul>
 *
 * @author Robert Futrell
 * @version 0.5
 *
 */
%%

%public
%class RubyTokenMaker
%extends AbstractJFlexTokenMaker
%unicode
%type org.fife.ui.rsyntaxtextarea.Token


%{

	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * an EOF heredoc.
	 */
	public static final int INTERNAL_HEREDOC_EOF			= -1;

	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * an EOT heredoc.
	 */
	public static final int INTERNAL_HEREDOC_EOT			= -2;

	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * a %Q!...! style double quoted string.
	 */
	public static final int INTERNAL_STRING_Q_BANG				= -3;

	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * a %Q{...} style double quoted string.
	 */
	public static final int INTERNAL_STRING_Q_CURLY_BRACE		= -4;

	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * a %Q&lt;...&gt; style double quoted string.
	 */
	public static final int INTERNAL_STRING_Q_LT					= -5;


	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * a %Q(...) style double quoted string.
	 */
	public static final int INTERNAL_STRING_Q_PAREN					= -6;


	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * a %Q/.../ style double quoted string.
	 */
	public static final int INTERNAL_STRING_Q_SLASH				= -7;

	/**
	 * Token type specific to RubyTokenMaker; this signals that we are inside
	 * a %Q[...] style double quoted string.
	 */
	public static final int INTERNAL_STRING_Q_SQUARE_BRACKET		= -8;


	/**
	 * Constructor.  This must be here because JFlex does not generate a
	 * no-parameter constructor.
	 */
	public RubyTokenMaker() {
	}


	/**
	 * Adds the token specified to the current linked list of tokens as an
	 * "end token;" that is, at <code>zzMarkedPos</code>.
	 *
	 * @param tokenType The token's type.
	 */
	private void addEndToken(int tokenType) {
		addToken(zzMarkedPos,zzMarkedPos, tokenType);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 * @see #addToken(int, int, int)
	 */
	private void addHyperlinkToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer, start,end, tokenType, so, true);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int tokenType) {
		addToken(zzStartRead, zzMarkedPos-1, tokenType);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param tokenType The token's type.
	 */
	private void addToken(int start, int end, int tokenType) {
		int so = start + offsetShift;
		addToken(zzBuffer, start,end, tokenType, so);
	}


	/**
	 * Adds the token specified to the current linked list of tokens.
	 *
	 * @param array The character array.
	 * @param start The starting offset in the array.
	 * @param end The ending offset in the array.
	 * @param tokenType The token's type.
	 * @param startOffset The offset in the document at which this token
	 *                    occurs.
	 */
	@Override
	public void addToken(char[] array, int start, int end, int tokenType, int startOffset) {
		super.addToken(array, start,end, tokenType, startOffset);
		zzStartRead = zzMarkedPos;
	}


	@Override
	public String[] getLineCommentStartAndEnd(int languageIndex) {
		return new String[] { "#", null };
	}


	/**
	 * Returns whether tokens of the specified type should have "mark
	 * occurrences" enabled for the current programming language.
	 *
	 * @param type The token type.
	 * @return Whether tokens of this type should have "mark occurrences"
	 *         enabled.
	 */
	public boolean getMarkOccurrencesOfTokenType(int type) {
		return type==TokenTypes.IDENTIFIER || type==TokenTypes.VARIABLE;
	}


	/**
	 * Returns the first token in the linked list of tokens generated
	 * from <code>text</code>.  This method must be implemented by
	 * subclasses so they can correctly implement syntax highlighting.
	 *
	 * @param text The text from which to get tokens.
	 * @param initialTokenType The token type we should start with.
	 * @param startOffset The offset into the document at which
	 *        <code>text</code> starts.
	 * @return The first <code>Token</code> in a linked list representing
	 *         the syntax highlighted text.
	 */
	public Token getTokenList(Segment text, int initialTokenType, int startOffset) {

		resetTokenList();
		this.offsetShift = -text.offset + startOffset;

		// Start off in the proper state.
		int state;
		switch (initialTokenType) {
			case TokenTypes.COMMENT_DOCUMENTATION:
				state = DOCCOMMENT;
				start = text.offset;
				break;
			case TokenTypes.LITERAL_STRING_DOUBLE_QUOTE:
				state = STRING;
				start = text.offset;
				break;
			case TokenTypes.LITERAL_CHAR:
				state = CHAR_LITERAL;
				start = text.offset;
				break;
			case TokenTypes.LITERAL_BACKQUOTE:
				state = BACKTICKS;
				start = text.offset;
				break;
			case INTERNAL_HEREDOC_EOF:
				state = HEREDOC_EOF;
				start = text.offset;
				break;
			case INTERNAL_HEREDOC_EOT:
				state = HEREDOC_EOT;
				start = text.offset;
				break;
			case INTERNAL_STRING_Q_BANG:
				state = STRING_Q_BANG;
				start = text.offset;
				break;
			case INTERNAL_STRING_Q_CURLY_BRACE:
				state = STRING_Q_CURLY_BRACE;
				start = text.offset;
				break;
			case INTERNAL_STRING_Q_LT:
				state = STRING_Q_LT;
				start = text.offset;
				break;
			case INTERNAL_STRING_Q_PAREN:
				state = STRING_Q_PAREN;
				start = text.offset;
				break;
			case INTERNAL_STRING_Q_SLASH:
				state = STRING_Q_SLASH;
				start = text.offset;
				break;
			case INTERNAL_STRING_Q_SQUARE_BRACKET:
				state = STRING_Q_SQUARE_BRACKET;
				start = text.offset;
				break;
			default:
				state = YYINITIAL;
		}

		s = text;
		try {
			yyreset(zzReader);
			yybegin(state);
			return yylex();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			return new TokenImpl();
		}

	}


	/**
	 * Refills the input buffer.
	 *
	 * @return      <code>true</code> if EOF was reached, otherwise
	 *              <code>false</code>.
	 */
	private boolean zzRefill() {
		return zzCurrentPos>=s.offset+s.count;
	}


	/**
	 * Resets the scanner to read from a new input stream.
	 * Does not close the old reader.
	 *
	 * All internal variables are reset, the old input stream 
	 * <b>cannot</b> be reused (internal buffer is discarded and lost).
	 * Lexical state is set to <tt>YY_INITIAL</tt>.
	 *
	 * @param reader   the new input stream 
	 */
	public final void yyreset(Reader reader) {
		// 's' has been updated.
		zzBuffer = s.array;
		/*
		 * We replaced the line below with the two below it because zzRefill
		 * no longer "refills" the buffer (since the way we do it, it's always
		 * "full" the first time through, since it points to the segment's
		 * array).  So, we assign zzEndRead here.
		 */
		//zzStartRead = zzEndRead = s.offset;
		zzStartRead = s.offset;
		zzEndRead = zzStartRead + s.count - 1;
		zzCurrentPos = zzMarkedPos = zzPushbackPos = s.offset;
		zzLexicalState = YYINITIAL;
		zzReader = reader;
		zzAtBOL  = true;
		zzAtEOF  = false;
	}


%}

Letter							= [A-Za-z]
NonzeroDigit						= [1-9]
Digit							= ("0"|{NonzeroDigit})
BinaryDigit							= ([01])
HexDigit							= ({Digit}|[A-Fa-f])
OctalDigit						= ([0-7])
NonSeparator						= ([^\t\f\r\n\ \(\)\{\}\[\]\;\,\.\=\>\<\!\~\?\:\+\-\*\/\&\|\^\%\"\'\`]|"#"|"\\")

IdentifierStart					= ({Letter}|"_")
IdentifierPart						= ({IdentifierStart}|{Digit})
BooleanLiteral				= ("true"|"false")

LineTerminator				= (\n)
WhiteSpace				= ([ \t\f])

LineCommentBegin			= "#"
DocCommentBegin				= "=begin"
DocCommentEnd				= "=end"

DigitOrUnderscore			= ({Digit}|[_])
BinaryIntLiteral			= ("0b"{BinaryDigit}([01_]*{BinaryDigit})?)
OctalLiteral				= ("0"([0-7_]*{OctalDigit})?)
DecimalLiteral1				= ("0d"{Digit}({DigitOrUnderscore}*{Digit})?)
DecimalLiteral2				= ({NonzeroDigit}({DigitOrUnderscore}*{Digit})?)
DecimalLiteral				= ({BinaryIntLiteral}|{OctalLiteral}|{DecimalLiteral1}|{DecimalLiteral2})
HexLiteral					= ("0x"{HexDigit}([0-9a-zA-Z_]*{HexDigit})?)
FloatLiteral				= ({NonzeroDigit}({DigitOrUnderscore}*{Digit})?[Ee][+-]?({Digit}({DigitOrUnderscore}*{Digit})?)?)

Separator					= ([\(\)\{\}\[\]])
Operator1					= ("::"|"."|"-"|"+"|"!"|"~"|"*"|"/"|"%"|"<<"|">>"|"&"|"|"|"^")
Operator2					= (">"|">="|"<"|"<="|"<=>"|"=="|"==="|"!="|"=~"|"!~"|"&&"|"||")
Operator3					= (".."|"..."|"="|"+="|"-="|"*="|"/="|"%=")
Operator					= ({Operator1}|{Operator2}|{Operator3})

Identifier				= ({IdentifierStart}{IdentifierPart}*)
Symbol					= ([:]{Identifier})
ErrorIdentifier			= ({NonSeparator}+)

PreDefinedVariable			= ("$"([!@&`\'+0-9~=/\,;.<>_*$?:\"]|"DEBUG"|"FILENAME"|"LOAD_PATH"|"stderr"|"stdin"|"stdout"|"VERBOSE"|([\-][0adFiIlpwv])))
Variable					= ({PreDefinedVariable}|([@][@]?|[$]){Identifier})

URLGenDelim				= ([:\/\?#\[\]@])
URLSubDelim				= ([\!\$&'\(\)\*\+,;=])
URLUnreserved			= ({Letter}|"_"|{Digit}|[\-\.\~])
URLCharacter			= ({URLGenDelim}|{URLSubDelim}|{URLUnreserved}|[%])
URLCharacters			= ({URLCharacter}*)
URLEndCharacter			= ([\/\$]|{Letter}|{Digit})
URL						= (((https?|f(tp|ile))"://"|"www.")({URLCharacters}{URLEndCharacter})?)

%state STRING
%state STRING_Q_BANG
%state STRING_Q_CURLY_BRACE
%state STRING_Q_PAREN
%state STRING_Q_SLASH
%state STRING_Q_SQUARE_BRACKET
%state STRING_Q_LT
%state CHAR_LITERAL
%state BACKTICKS
%state HEREDOC_EOF
%state HEREDOC_EOT
%state DOCCOMMENT

%%

<YYINITIAL> {

	/* Keywords */
	"alias" |
	"BEGIN" |
	"begin" |
	"break" |
	"case" |
	"class" |
	"def" |
	"defined" |
	"do" |
	"else" |
	"elsif" |
	"END" |
	"end" |
	"ensure" |
	"for" |
	"if" |
	"in" |
	"module" |
	"next" |
	"nil" |
	"private" |
	"protected" |
	"public" |
	"redo" |
	"rescue" |
	"retry" |
	"return" |
	"self" |
	"super" |
	"then" |
	"undef" |
	"unless" |
	"until" |
	"when" |
	"while" |
	"yield"					{ addToken(TokenTypes.RESERVED_WORD); }

	"Array" |
	"Float" |
	"Integer" |
	"String" |
	"at_exit" |
	"autoload" |
	"binding" |
	"caller" |
	"catch" |
	"chop" |
	"chop!" |
	"chomp" |
	"chomp!" |
	"eval" |
	"exec" |
	"exit" |
	"exit!" |
	"fail" |
	"fork" |
	"format" |
	"gets" |
	"global_variables" |
	"gsub" |
	"gsub!" |
	"iterator?" |
	"lambda" |
	"load" |
	"local_variables" |
	"loop" |
	"open" |
	"p" |
	"print" |
	"printf" |
	"proc" |
	"putc" |
	"puts" |
	"raise" |
	"rand" |
	"readline" |
	"readlines" |
	"require" |
	"select" |
	"sleep" |
	"split" |
	"sprintf" |
	"srand" |
	"sub" |
	"sub!" |
	"syscall" |
	"system" |
	"test" |
	"trace_var" |
	"trap" |
	"untrace_var"					{ addToken(TokenTypes.FUNCTION); }

	"and" |
	"or" |
	"not"					{ addToken(TokenTypes.OPERATOR); }

	{BooleanLiteral}			{ addToken(TokenTypes.LITERAL_BOOLEAN); }

	{Variable}						{ addToken(TokenTypes.VARIABLE); }
	{Symbol}						{ addToken(TokenTypes.PREPROCESSOR); }

	{LineTerminator}				{ addNullToken(); return firstToken; }
	{Identifier}					{ addToken(TokenTypes.IDENTIFIER); }
	{WhiteSpace}+					{ addToken(TokenTypes.WHITESPACE); }

	/* String/Character literals. */
	\"							{ start = zzMarkedPos-1; yybegin(STRING); }
	\'							{ start = zzMarkedPos-1; yybegin(CHAR_LITERAL); }
	[\%][QqWwx]?[\(]			{ start = zzMarkedPos-yylength(); yybegin(STRING_Q_PAREN); }
	[\%][QqWwx]?[\{]			{ start = zzMarkedPos-yylength(); yybegin(STRING_Q_CURLY_BRACE); }
	[\%][QqWwx]?[\[]			{ start = zzMarkedPos-yylength(); yybegin(STRING_Q_SQUARE_BRACKET); }
	[\%][QqWwx]?[\<]			{ start = zzMarkedPos-yylength(); yybegin(STRING_Q_LT); }
	[\%][QqWwx]?[\!]			{ start = zzMarkedPos-yylength(); yybegin(STRING_Q_BANG); }
	[\%][QqWwx]?[\/]			{ start = zzMarkedPos-yylength(); yybegin(STRING_Q_SLASH); }
	\`							{ start = zzMarkedPos-1; yybegin(BACKTICKS); }

	/* Comment literals. */
	{LineCommentBegin}.*			{ addToken(TokenTypes.COMMENT_EOL); addNullToken(); return firstToken; }
	{DocCommentBegin}				{ start = zzMarkedPos-6; yybegin(DOCCOMMENT); }

	/* "Here-document" syntax.  This is only implemented for the common */
	/* cases.                                                           */
	"<<EOF" |
	"<<" {WhiteSpace}* \""EOF"\" |
	"<<" {WhiteSpace}* \'"EOF"\' |
	"<<" {WhiteSpace}* \`"EOF"\`		{ start = zzStartRead; yybegin(HEREDOC_EOF); }
	"<<EOT" |
	"<<" {WhiteSpace}* \""EOT"\" |
	"<<" {WhiteSpace}* \'"EOT"\' |
	"<<" {WhiteSpace}* \`"EOT"\`		{ start = zzStartRead; yybegin(HEREDOC_EOT); }

	/* Separators and operators. */
	{Separator}					{ addToken(TokenTypes.SEPARATOR); }
	{Operator}					{ addToken(TokenTypes.OPERATOR); }

	/* Numbers */
	{DecimalLiteral}				{ addToken(TokenTypes.LITERAL_NUMBER_DECIMAL_INT); }
	{HexLiteral}					{ addToken(TokenTypes.LITERAL_NUMBER_HEXADECIMAL); }
	{FloatLiteral}					{ addToken(TokenTypes.LITERAL_NUMBER_FLOAT); }

	{ErrorIdentifier}				{ addToken(TokenTypes.ERROR_IDENTIFIER); }

	/* Ended with a line not in a string or comment. */
	<<EOF>>						{ addNullToken(); return firstToken; }

	/* Catch any other (unhandled) characters. */
	.							{ addToken(TokenTypes.IDENTIFIER); }

}


<STRING> {
	[^\n\\\"]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\"					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); return firstToken; }
}


<STRING_Q_BANG> {
	[^\n\\\!]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\!					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); addEndToken(INTERNAL_STRING_Q_BANG); return firstToken; }
}


<STRING_Q_CURLY_BRACE> {
	[^\n\\\}]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\}					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); addEndToken(INTERNAL_STRING_Q_CURLY_BRACE); return firstToken; }
}


<STRING_Q_LT> {
	[^\n\\\>]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\>					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); addEndToken(INTERNAL_STRING_Q_LT); return firstToken; }
}


<STRING_Q_PAREN> {
	[^\n\\\)]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\)					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); addEndToken(INTERNAL_STRING_Q_PAREN); return firstToken; }
}


<STRING_Q_SLASH> {
	[^\n\\\/]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\/					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); addEndToken(INTERNAL_STRING_Q_SLASH); return firstToken; }
}


<STRING_Q_SQUARE_BRACKET> {
	[^\n\\\]]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\]					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_STRING_DOUBLE_QUOTE); addEndToken(INTERNAL_STRING_Q_SQUARE_BRACKET); return firstToken; }
}


<CHAR_LITERAL> {
	[^\n\\\']+			{}
	\\.?					{ /* Skip escaped single quotes only, but this should still work. */ }
	\'					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_CHAR); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_CHAR); return firstToken; }
}


<BACKTICKS> {
	[^\n\\\`]+		{}
	\\.?					{ /* Skip escaped chars. */ }
	\`					{ yybegin(YYINITIAL); addToken(start,zzStartRead, TokenTypes.LITERAL_BACKQUOTE); }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.LITERAL_BACKQUOTE); return firstToken; }
}


<HEREDOC_EOF> {
	/* NOTE: The closing "EOF" is supposed to be on a line by itself -  */
	/* no surrounding whitespace or other chars.  However, the way      */
	/* we're hacking the JFLex scanning, something like ^"EOF"$ doesn't */
	/* work.  Fortunately we don't need the start- and end-line anchors */
	/* since the production after "EOF" will match any line containing  */
	/* EOF and any other chars.                                         */
	/* NOTE2: This case is used for unquoted <<EOF, double quoted       */
	/* <<"EOF", single-quoted <<'EOF' and backticks <<`EOF`, since they */
	/* all follow the same syntactic rules.                              */
	"EOF"				{ if (start==zzStartRead) { addToken(TokenTypes.PREPROCESSOR); addNullToken(); return firstToken; } }
	[^\n\\]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.PREPROCESSOR); addEndToken(INTERNAL_HEREDOC_EOF); return firstToken; }
}


<HEREDOC_EOT> {
	/* NOTE: The closing "EOT" is supposed to be on a line by itself -  */
	/* no surrounding whitespace or other chars.  However, the way      */
	/* we're hacking the JFLex scanning, something like ^"EOT"$ doesn't */
	/* work.  Fortunately we don't need the start- and end-line anchors */
	/* since the production after "EOT" will match any line containing  */
	/* EOF and any other chars.                                         */
	/* NOTE2: This case is used for unquoted <<EOT, double quoted       */
	/* <<"EOT", single-quoted <<'EOT' and backticks <<`EOT`, since they */
	/* all follow the same syntactic rules.                              */
	"EOT"				{ if (start==zzStartRead) { addToken(TokenTypes.PREPROCESSOR); addNullToken(); return firstToken; } }
	[^\n\\]+			{}
	\\.?					{ /* Skip escaped chars. */ }
	\n |
	<<EOF>>				{ addToken(start,zzStartRead-1, TokenTypes.PREPROCESSOR); addEndToken(INTERNAL_HEREDOC_EOT); return firstToken; }
}


<DOCCOMMENT> {

	[^hwf\n=]+				{}
	{URL}					{
                                int temp = zzStartRead;
                                if (start <= zzStartRead - 1) {
                                    addToken(start,zzStartRead-1, Token.COMMENT_DOCUMENTATION);
                                }
                                addHyperlinkToken(temp,zzMarkedPos-1, Token.COMMENT_DOCUMENTATION);
                                start = zzMarkedPos;
                            }
	[hwf]					{}

	{DocCommentEnd}			{ yybegin(YYINITIAL); addToken(start,zzStartRead+3, TokenTypes.COMMENT_DOCUMENTATION); }
	=			    		{}
	\n |
	<<EOF>>					{ yybegin(YYINITIAL); addToken(start,zzEndRead, TokenTypes.COMMENT_DOCUMENTATION); return firstToken; }
}
