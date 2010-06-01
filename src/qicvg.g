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
	ROW;
	SCALE;
	ANGLE;
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

prog 	:	row? (ENDL row?)* -> ^(ROW row)*;

INT :	'0'..'9'+ ;

FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

COMMENT
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
	:	'orange'|'blue'|'aqua'| 'black'| 'fuchsia'| 'gray'| 'green'| 'lime'| 'maroon'| 'navy'| 'olive'| 'purple'| 'red'| 'silver'|' teal'|' white'| 'yellow';

row 	:	def COMMENT? |COMMENT ;	

def	:	'line' ID '(' point ',' point (',' nfstyle)? ')' -> ^('line' ID ^(INITPOSITION point) ^(FINALPOSITION point) nfstyle?)
	|	'path' ID '(' point (',' style)? ')' ('.' pathel)* -> ^('path' ID ^(POSITION point) style? pathel*)
	|	'square' ID '(' point ',' coord (','style)? ')' -> ^('square' ID ^(POSITION point) ^(SIDELEN coord) style?)
	| 'circle' ID '(' point ',' coord (','style)? ')' -> ^('circle' ID ^(POSITION point) ^(RADIUS coord) style?)
	|	'rect' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('rect' ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	| 'ellipse' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('ellipse' ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	|	'star' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('star' ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	| 'polreg' ID '(' point ',' coord ',' coord (','style)? ')' -> ^('polreg' ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	|	'container' ID '(' point ')' '[' ( ENDL containerrow? )* ']' -> ^('container' ID ^(POSITION point) ^(ROW containerrow)*)
	| 'style' ID '(' styledef ')' -> ^('style' ID styledef)  | 'nfstyle' ID '(' nfstyledef ')' -> ^('nfstyle' ID nfstyledef)
	
	;
	
containerrow	:	innerdef COMMENT? |COMMENT ;

innerdef: 
    def
  | ID ID '(' point (',' FLOAT (',' FLOAT)?)? ')' -> ^(ID ID ^(POSITION point) ^(SCALE FLOAT)? ^(ANGLE FLOAT)?);
	
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


