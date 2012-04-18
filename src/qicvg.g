grammar qicvg;

options{
	output=AST;
	ASTLabelType = QicvgTree;
}

tokens {
	MATH;
	POSITION;
	HORIZLEN;
	VERTLEN;
	RADIUS;
	VERTEXES;
	SIDELEN;
	INITPOSITION;
	FINALPOSITION;
	STYLE;
	BORDERCOLOR;
	FILLCOLOR;
	BORDERWIDTH;
	CLOSE;
	BEZIER;
	SHORTHANDBEZIER;
	QUADRATICBEZIER;
	SHORTHANDQUADRATICBEZIER;
	CONTROLPOINT;
	MOVETO;
	LINETO;
	HORIZONTALLINE;
	VERTICALLINE;
	SCALE;
	ANGLE;
	COMMENT;
}

@header {

  package qicvg;
  import java.util.HashMap;
  import java.util.ArrayList;
}

@members {
  HashMap<String,ArrayList<QicvgTree>> containers = new HashMap<String,ArrayList<QicvgTree>>();
  //TODO: non supporta gli scope
   
	List<RecognitionException> exceptions = new ArrayList<RecognitionException>();

	public List<RecognitionException> getExceptions() {
		return exceptions;
	}

	@Override
	public void reportError(RecognitionException e) {
		super.reportError(e);
		exceptions.add(e);
	}

}

prog 	:	row? (ENDL row?)* -> row*;

INT :	'0'..'9'+ ;

FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

COMMENTTEXT
    :   '//' ~('\n'|'\r')* 
    ;

WS  :   ( ' '
        | '\t'
        | '\r'
        ) {$channel=HIDDEN;}
    ;
    
ENDL  	:  ('\r')?'\n'  ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;

CHAR:  '\'' ( ESC_SEQ | ~('\''|'\\') ) '\''
    ;

fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

HEXNUMBER
	:	'#' HEX_DIGIT HEX_DIGIT HEX_DIGIT ( HEX_DIGIT HEX_DIGIT HEX_DIGIT )?;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;
    
IDATTRIB  
	:	('x'|'y'|'x2'|'y2'|'height'|'width'|'nvert'|'r'|'cx'|'cy'|'rx'|'ry')
	;

COLORNAME
	:	'orange'|'blue'|'aqua'| 'black'| 'fuchsia'| 'gray'| 'green'| 'lime'| 'maroon'| 'navy'| 'olive'| 'purple'| 'red'| 'silver'| 'teal'|' white'| 'yellow';

row 	:	def comment? | comment;
      
comment : COMMENTTEXT -> ^(COMMENT {new QicvgTree(new CommonToken(COMMENTTEXT,$COMMENTTEXT.text.substring(2)))});

def	:	'line' ID '(' point ',' point (',' nfstyle)? ')' -> ^('line' ID ^(INITPOSITION point) ^(FINALPOSITION point) nfstyle?)
	|	'path' ID '(' point (',' style)? ')' ('.' pathel)* -> ^('path' ID ^(POSITION point) style? pathel*)
	|	'square' ID '(' point ',' coord (','style)? ')' -> ^('square' ID ^(POSITION point) ^(SIDELEN coord) style?)
	| 'circle' ID '(' point ',' coord (','style)? ')' -> ^('circle' ID ^(POSITION point) ^(RADIUS coord) style?)
	|	'rect' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('rect' ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	| 'ellipse' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('ellipse' ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	|	'star' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('star' ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	| 'polreg' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('polreg' ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	|	'container' ID '(' INT ',' INT ')' '[' ( ENDL (elements+=containerrow?) )* ']' {
	   containers.put($ID.text,(ArrayList<QicvgTree>) $elements);
	} -> ^('container' ID ^(POSITION INT INT) containerrow* ) // TODO: non è possibile specificare un container seguito da un commento prima delle istruzioni contenute... valutare
	| 'style' ID '(' styledef ')' -> ^('style' ID styledef)  | 'nfstyle' ID '(' nfstyledef ')' -> ^('nfstyle' ID nfstyledef)
	;
	
containerrow	:	innerdef comment? | comment;

innerdef: 
    def
  | ID ID '(' point (',' scale=number (',' angle=number)?)? ')' -> ^(ID ID ^(POSITION point) ^(SCALE $scale)? ^(ANGLE $angle)?);
	
style 	:	styledef
	|	ID  ;
	
styledef:	(c1=color?','c2=color?','INT?) -> ^(STYLE ^(FILLCOLOR $c1)? ^(BORDERCOLOR $c2)? ^(BORDERWIDTH INT)?);

nfstyle	:	nfstyledef
	|	ID;
	
nfstyledef
	:	(color?','INT) -> ^(STYLE ^(BORDERCOLOR color)? ^(BORDERWIDTH INT)?);
	
point	:	coord ',' coord -> coord coord;

pathel	:	'M''('point')' -> ^(MOVETO ^(POSITION point))
	|	'L''('point')' -> ^(LINETO ^(POSITION point))
	|	'Z()' -> CLOSE
	|	'H''('coord')' -> ^(HORIZONTALLINE coord)
	|	'V''('coord')' -> ^(VERTICALLINE coord)
	|	'C('point','point','point')' -> ^(BEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point) ^(CONTROLPOINT point) )
	|	'S('point','point')' -> ^(SHORTHANDBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point) )
	|	'T('point(','point)*')' -> ^(SHORTHANDQUADRATICBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point)* )
	|	'Q('point(','point)+')' -> ^(QUADRATICBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point)+ )
	;

color	: COLORNAME | HEXNUMBER;

math	:	term(('+'|'-')^term)* ;

term	:	atom(('*'|'/')^atom)*;

coord	:	math ;

//TODO: permettere di usare +/- unari per le espressioni, e non solo per i numeri
atom	:	number
	|	'(' math ')' -> ^(MATH math) 
	|	ID'.'IDATTRIB -> ^(ID IDATTRIB) ;

number : ('+'^|'-'^)?(INT|FLOAT);

ID	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
		;
