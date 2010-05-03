tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
}

INT :	'0'..'9'+
    ;

FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;
  
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


prog 	:	(def|defs)*;

defs	:	^(('style'|'nfstyle') ID styledef);

def	:	^('line' ID ^(INITPOSITION point) ^(FINALPOSITION point) style?)
	|	^('path' ID ^(POSITION point) style? pathel*)
	|	^(SHAPE ID ^(POSITION point) ^(SIDELEN coord) style?)
	|	^(SHAPE ID ^(POSITION point) ^(RADIUS coord) style?) 
	|	^(REGULARSHAPE ID ^(POSITION point) ^(HORIZLEN coord) ^(VERTLEN coord) style?)
	|	^(COMPLEXSHAPE ID ^(POSITION point) ^(RADIUS coord) ^(VERTEXES coord) style?)
	|	^('container' ID ^(POSITION point) (containerrow)*)
	;
	
containerrow	:	def
		|defs
		|innerdef;

innerdef:	^(ID ID ^(INITPOSITION point) ^(FINALPOSITION point));
	
style	:	styledef | ID;

styledef 	:	^(STYLE ^(FILLCOLOR color)? ^(BORDERCOLOR color)? ^(BORDERWIDTH INT)?);
	
point	:	coord coord;

pathel	:	^(MOVETO ^(POSITION point))
	|	^(LINETO ^(POSITION point))
	|	CLOSE
	|	^(HORIZONTALLINE coord)
	|	^(VERTICALLINE coord)
	|	^(BEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point) ^(CONTROLPOINT point) )
	|	^(SHORTHANDBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point) )
	|	^(SHORTHANDQUADRATICBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point)* )
	|	^(QUADRATICBEZIER ^(CONTROLPOINT point) ^(CONTROLPOINT point)+ )
	;

color	:	COLORNAME|HEXNUMBER;

math	:	('+'|'-')?term(('+'|'-')term)*;

term	:	atom(('*'|'/')atom)*;

coord	:	math -> ^(MATH math);

atom	:	INT|^(MATH math) | ^(ID IDATTRIB) ;

ID	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
		;


