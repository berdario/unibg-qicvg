grammar qicvg;

prog 	:	row? (ENDL row?)* ;

row 	:	(def|defs)? COMMENT?;

defs	:	'stile'ID'('style')'|'nfstile' ID'('nfstyle')';

def	:	'line'ID'('point','point(','nfstyle)?')'
	|	'path'ID'('point(','style)?')'pathspec
	|	SHAPE ID'('point','coord(','style)?')'
	|	(REGULARSHAPE|COMPLEXSHAPE) ID'('point','coord','coord(','style)?')'
	;
	
style 	:	 ((color','color','INT)|ID);

nfstyle	:	((color','INT)|ID);
	
SHAPE	:	'circle'|'square';

REGULARSHAPE
	:	'rect'|'ellipse';

COMPLEXSHAPE:	'polreg'|'star';

point	:	coord','coord;

pathspec:	('.'pathel pathspec)?;

pathel	:	POINTEL'('point')'
	|	'Z()'
	|	COORDEL'('coord')'
	|	'C('point','point','point')'
	|	'S('point','point')'
	|	'T('point(','point)*')'
	|	'Q('point(','point)+')'
	;

color	:	(COLORNAME|'#'HEX_DIGIT HEX_DIGIT HEX_DIGIT|'#'HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT)?;

term	:	coord(('*'|'/')coord)*;

math	:	term(('+'|'-')term)*;

coord	:	INT|'('math')'|ID'.'IDATTRIB;
    
IDATTRIB  
	:	('x'|'y'|'x2'|'y2'|'dim1'|'dim2'|'nvert'|'r')
	;

POINTEL	:	'M'|'L';

COORDEL	:	'H'|'V';

ID	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
		;


INT :	'0'..'9'+
    ;

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

COLORNAME
	:	'orange'|'blue'|'aqua'| 'black'| 'fuchsia'| 'gray'| 'green'| 'lime'| 'maroon'| 'navy'| 'olive'| 'purple'| 'red'| 'silver'|' teal'|' white'| 'yellow';

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;
