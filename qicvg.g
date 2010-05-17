grammar qicvg;

options{
	output=AST;
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
}

@members {

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

COMMENT
    :   '//' ~('\n'|'\r')* {$channel=HIDDEN;}
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
	:	('x'|'y'|'x2'|'y2'|'dim1'|'dim2'|'nvert'|'r')
	;

COLORNAME
	:	'orange'|'blue'|'aqua'| 'black'| 'fuchsia'| 'gray'| 'green'| 'lime'| 'maroon'| 'navy'| 'olive'| 'purple'| 'red'| 'silver'|' teal'|' white'| 'yellow';
	
SHAPE	:	'circle'|'square';

REGULARSHAPE
	:	'rect'|'ellipse';

COMPLEXSHAPE:	'polreg'|'star';



row 	:	(def|defs) COMMENT?|COMMENT;

defs	:	'style' ID '(' styledef ')' -> ^('style' ID styledef)  | 'nfstyle' ID '(' nfstyledef ')' -> ^('nfstyle' ID nfstyledef);

def	:	'line' ID '(' point ',' point (',' nfstyle)? ')' -> ^('line' ID ^(INITPOSITION point) ^(FINALPOSITION point) nfstyle?)
	|	'path' ID '(' point (',' style)? ')' ('.' pathel)* -> ^('path' ID ^(POSITION point) style? pathel*)
	|	tempshape
	|	REGULARSHAPE ID '(' point ',' coord ',' coord (','style)? ')' -> ^(REGULARSHAPE ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	|	COMPLEXSHAPE ID '(' point ',' coord ',' coord (','style)? ')' -> ^(COMPLEXSHAPE ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	|	'container' ID '(' point ')' '[' ( ENDL containerrow? )* ']' -> ^('container' ID ^(POSITION point) (containerrow)*)
	;
	
tempshape	:	SHAPE ID '(' point ',' coord (','style)? ')' -> {$SHAPE.text=="square"}? ^(SHAPE ID ^(POSITION point) ^(SIDELEN coord) style?)
								-> ^(SHAPE ID ^(POSITION point) ^(RADIUS coord) style?) ;
	
containerrow	:	(def|defs|innerdef) COMMENT?|COMMENT;

innerdef:	ID ID '(' point ',' point ')' -> ^(ID ID ^(INITPOSITION point) ^(FINALPOSITION point));
	
style 	:	styledef
	|	ID  ;
	
styledef:	(color?','color?','INT?) -> ^(STYLE ^(FILLCOLOR color)? ^(BORDERCOLOR color)? ^(BORDERWIDTH INT)?);

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

color	:	COLORNAME|HEXNUMBER;

math	:	term(('+'|'-')^term)* ;

term	:	atom(('*'|'/')^atom)*;

coord	:	math ;

atom	:	('+'|'-')?INT
	|	'(' math ')' -> ^(MATH math) 
	|	ID'.'IDATTRIB -> ^(ID IDATTRIB) ;

ID	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
		;


