/*
 * 03/23/2005
 *
 * FortranTokenMaker.java - Scanner for the Fortran programming language.
 * 
 * This library is distributed under a modified BSD license.  See the included
 * LICENSE file for details.
 */
package org.fife.ui.rsyntaxtextarea.modes;

import java.io.*;
import javax.swing.text.Segment;

import org.fife.ui.rsyntaxtextarea.*;


/**
 * Scanner for the Fortran programming language.
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
 *   <li>The generated <code>FortranTokenMaker.java</code> file will contain two
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
 * @version 0.4
 *
 */
%%

%public
%class FortranTokenMaker
%extends AbstractJFlexTokenMaker
%unicode
%ignorecase
%type org.fife.ui.rsyntaxtextarea.Token


%{


	/**
	 * Constructor.  We must have this here as there is no default,
	 * no-parameter constructor generated by JFlex.
	 */
	public FortranTokenMaker() {
		super();
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
		return new String[] { "!", null };
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
		int state = Token.NULL;
		switch (initialTokenType) {
			case Token.LITERAL_STRING_DOUBLE_QUOTE:
				state = STRING;
				start = text.offset;
				break;
			case Token.LITERAL_CHAR:
				state = CHAR;
				start = text.offset;
				break;
			default:
				state = Token.NULL;
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

LineTerminator			= (\n)
WhiteSpace			= ([ \t\f])

Column1CommentBegin		= ([C\*])
Column1Comment2Begin	= (D)
AnywhereCommentBegin	= (\!)

Identifier			= ([A-Za-z0-9_$]+)

StringDelimiter		= (\")
CharDelimiter			= (\')

Operators1			= ("<"|">"|"<="|">="|"&"|"/="|"==")
Operators2			= (\.(lt|gt|eq|ne|le|ge|and|or)\.)
Operator				= ({Operators1}|{Operators2})

Boolean				= (\.(true|false)\.)

%state STRING
%state CHAR

%%

/* Keywords */
<YYINITIAL> "INCLUDE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "PROGRAM"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MODULE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SUBROUTINE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "FUNCTION"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CONTAINS"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "USE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CALL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "RETURN"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IMPLICIT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "EXPLICIT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "NONE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DATA"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "PARAMETER"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ALLOCATE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ALLOCATABLE"			{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ALLOCATED"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DEALLOCATE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "INTEGER"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "REAL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DOUBLE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "PRECISION"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "COMPLEX"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LOGICAL"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CHARACTER"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DIMENSION"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "KIND"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CASE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SELECT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DEFAULT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CONTINUE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CYCLE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DO"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "WHILE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ELSE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IF"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ELSEIF"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "THEN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ELSEWHERE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "END"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ENDIF"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ENDDO"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "FORALL"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "WHERE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "EXIT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "GOTO"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "PAUSE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "STOP"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "BACKSPACE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CLOSE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ENDFILE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "INQUIRE"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "OPEN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "PRINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "READ"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "REWIND"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "WRITE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "FORMAT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AIMAG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMAX0"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMIN0"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ANINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CEILING"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CMPLX"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CONJG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DBLE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DCMPLX"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DFLOAT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DIM"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DPROD"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "FLOAT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "FLOOR"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IFIX"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IMAG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "INT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LOGICAL"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MODULO"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "NINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "REAL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SIGN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SNGL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "TRANSFER"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ZEXT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ABS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ACOS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AIMAG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ALOG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ALOG10"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMAX0"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMAX1"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMIN0"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMIN1"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "AMOD"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ANINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ASIN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ATAN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ATAN2"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CABS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CCOS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CHAR"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CLOG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CMPLX"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CONJG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "COS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "COSH"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CSIN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "CSQRT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DABS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DACOS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DASIN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DATAN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DATAN2"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DBLE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DCOS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DCOSH"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DDIM"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DEXP"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DIM"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DLOG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DLOG10"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DMAX1"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DMIN1"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DMOD"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DNINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DPROD"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DREAL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DSIGN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DSIN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DSINH"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DSQRT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DTAN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "DTANH"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "EXP"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "FLOAT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IABS"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ICHAR"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IDIM"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IDINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IDNINT"				{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "IFIX"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "INDEX"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "INT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "ISIGN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LEN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LGE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LGT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LLE"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LLT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LOG"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "LOG10"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MAX"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MAX0"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MAX1"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MIN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MIN0"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MIN1"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "MOD"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "NINT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "REAL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SIGN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SIN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SINH"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SNGL"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "SQRT"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "TAN"					{ addToken(Token.RESERVED_WORD); }
<YYINITIAL> "TANH"					{ addToken(Token.RESERVED_WORD); }

<YYINITIAL> {

	{LineTerminator}				{ addNullToken(); return firstToken; }

	{WhiteSpace}+					{ addToken(Token.WHITESPACE); }

	/* String/Character Literals. */
	{CharDelimiter}				{ start = zzMarkedPos-1; yybegin(CHAR); }
	{StringDelimiter}				{ start = zzMarkedPos-1; yybegin(STRING); }

	/* Comment Literals. */
	/* Note that we cannot combine these as JFLex doesn't like combining an */
	/* expression containing the beginning-of-line character '^'. */
	{Column1CommentBegin}	{
							// Since we change zzStartRead, we have the unfortunate
							// side-effect of not being able to use the '^' operator.
							// So we must check whether we're really at the beginning
							// of the line ourselves...
							if (zzStartRead==s.offset) {
								addToken(zzStartRead,zzEndRead, Token.COMMENT_EOL);
								addNullToken();
								return firstToken;
							}
							else {
								addToken(Token.IDENTIFIER);
							}
						}
	{Column1Comment2Begin}	{
							// Since we change zzStartRead, we have the unfortunate
							// side-effect of not being able to use the '^' operator.
							// So we must check whether we're really at the beginning
							// of the line ourselves...
							if (zzStartRead==s.offset) {
								addToken(zzStartRead,zzEndRead, Token.COMMENT_DOCUMENTATION);
								addNullToken();
								return firstToken;
							}
							else {
								addToken(Token.IDENTIFIER);
							}
						}
	{AnywhereCommentBegin}	{ addToken(zzStartRead,zzEndRead, Token.COMMENT_EOL); addNullToken(); return firstToken; }

	/* Operators. */
	{Operator}					{ addToken(Token.OPERATOR); }

	/* Boolean literals. */
	{Boolean}						{ addToken(Token.LITERAL_BOOLEAN); }

	{Identifier}					{ addToken(Token.IDENTIFIER); }

	/* Ended with a line not in a string or char literal. */
	<<EOF>>						{ addNullToken(); return firstToken; }

	/* Catch any other (unhandled) characters. */
	.							{ addToken(Token.IDENTIFIER); }

}

<CHAR> {
	[^\'\n]*						{}
	\'							{ yybegin(YYINITIAL); addToken(start,zzStartRead, Token.LITERAL_CHAR); }
	\n							{ addToken(start,zzStartRead-1, Token.LITERAL_CHAR); return firstToken; }
	<<EOF>>						{ addToken(start,zzStartRead-1, Token.LITERAL_CHAR); return firstToken; }
}

<STRING> {
	[^\"\n]*						{}
	\"							{ yybegin(YYINITIAL); addToken(start,zzStartRead, Token.LITERAL_STRING_DOUBLE_QUOTE); }
	\n							{ addToken(start,zzStartRead-1, Token.LITERAL_STRING_DOUBLE_QUOTE); return firstToken; }
	<<EOF>>						{ addToken(start,zzStartRead-1, Token.LITERAL_STRING_DOUBLE_QUOTE); return firstToken; }
}
