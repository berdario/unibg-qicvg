tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
    output=template;
}

@header{
  import java.util.HashMap;
}

@members{
  HashMap<String,HashMap<String,Number>> vars = new HashMap<String,HashMap<String,Number>>(); 
  HashMap<String,HashMap<String,Object>> containerDefs = new HashMap<String,HashMap<String,Object>>(); 
  
  HashMap<String,Number> initVar(String id){
       if (vars.get(id) != null) {
         System.out.println("id trovato");//recuperare riga
         
       }
       HashMap<String, Number> var = new HashMap<String, Number>();
       vars.put(id,var);
       return var;
  }
  
  HashMap<String,Object> initContainer(String id){
       if (vars.get(id) != null) {
         //TODO throw eccezione
       }
       HashMap<String, Object> container = new HashMap<String, Object>();
       containerDefs.put(id,container);
       return container;
  }
  
  public static String getStarPath(double x,double y,double radius,Number n){
   
   
   //per testing inserisco dei valori
    
    int nv = n.intValue();
    ArrayList<Double> ArrayExternal = new ArrayList<Double>();
    ArrayList<Double> ArrayInternal = new ArrayList<Double>();
    
    //commento radius perché genera errore, uso un raggio arbitrario
    //int radius=new Integer(r);
    
    double initx=x;
    double inity=y;
    double coordx;
    double coordy;
    
    //System.out.println("inizio il ciclo");  
    for (int i=0;i<nv;i++)
    {
      //la nuova coordinata x si modifica del fattore cos dell'angolo 
      coordx=initx+radius*Math.cos((2*Math.PI/nv)*i);
      ArrayExternal.add(coordx);
      //la nuova coordinata y si modifica del fattore sen dell'angolo
      coordy=inity+radius*Math.sin((2*Math.PI/nv)*i);
      ArrayExternal.add(coordy);
        
    }
    //passo al calcolo dei punti interni
    //inizializzo il primo punto, il quale sarà orientato 
    //della meta dei gradi della corona esterna
    //il raggio interno è proporzionale all'esterno.
    double intradius = radius/4;
    //System.out.println("inizio il ciclo");  
    for (int i=0;i<nv;i++)
    {
      //la nuova coordinata x si modifica del fattore cos dell'angolo 
      coordx=initx+intradius*Math.cos(((2*Math.PI/nv)*i)+Math.PI/nv);
      ArrayInternal.add(coordx);
      //la nuova coordinata y si modifica del fattore sen dell'angolo
      coordy=inity+intradius*Math.sin(((2*Math.PI/nv)*i)+Math.PI/nv);
      ArrayInternal.add(coordy);
        
    }
    //inserisco nell'output i punti presi alternativamente dai due array
    //inizializzo il path
    
    String path = "M "+Math.round(ArrayExternal.get(0))+" "+Math.round(ArrayExternal.get(1))+" ";
            path+="L "+Math.round(ArrayInternal.get(0))+" "+Math.round(ArrayInternal.get(1))+" ";
    for (int i=2;i<ArrayExternal.size();i++) {
           path+="L "+Math.round(ArrayExternal.get(i))+" "+Math.round(ArrayExternal.get(i+1))+" ";
           path+="L "+Math.round(ArrayInternal.get(i))+" "+Math.round(ArrayInternal.get(i+1))+" ";
           i++;
         } 
    path += "Z";
    //System.out.println(path);
    //System.out.println("la stella esterna ha " + ArrayExternal.size()/2 + " elementi");
    //System.out.println("la stella interna ha " + ArrayExternal.size()/2 + " elementi");
    return path;
  }

      
   public static String getPolygonPath(double x, double y, double radius, Number n){
    int nv = n.intValue(); //TODO avoid rounding
    double internalarc=0;
    if (nv == 3){
      
      internalarc=120*Math.PI/180;
      //y+=radius;
      //radius*=2;
    } else if (nv > 3){
      //calculate polygon's internal angle
      internalarc=(360/nv)*Math.PI/180;
    }
    
    double currentx = x;
    double currenty = y-radius;
    
    //calculate side length
    double side = 2*radius*Math.sin(Math.PI/nv);
    
    //setting path's initial coords
    String path = "M "+Math.round(currentx)+" "+Math.round(currenty)+" ";
    
    double currentarc=-internalarc/2;
    
    while(currentarc > -2 * Math.PI){
      currentx-=Math.cos(currentarc)*side;
      currenty-=Math.sin(currentarc)*side;
      path+="L "+Math.round(currentx)+" "+Math.round(currenty)+" ";
      currentarc-=internalarc;
    }
    path+="Z";
    return path;
  }
}

prog 	:	(^(ROW def comment?) | ^(ROW comment))*;

comment: COMMENT -> template(c={$COMMENT.text}) "\<!--<c>--\>" ;

def returns [String id]:
  	^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) 
  	 {
  	   $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("x1",$p1.c1);
       var.put("y1",$p1.c2);
       var.put("x2",$p2.c1);
       var.put("y2",$p2.c2);
     }
  	 -> line(id={$ID.text},x1={$p1.c1},y1={$p1.c2},x2={$p2.c1},y2={$p2.c2},style={$style.text})
	|	^('path' ID ^(POSITION point) style? pathelements+=pathel*) 
	   -> path(id={$ID.text},point={$point.text},pathelements={$pathelements},style={$style.text})
	|	^('square' ID ^(POSITION point) ^(SIDELEN expr) style?) 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("size",$expr.val);
     }
	   -> square(id={$ID.text},x={$point.c1},y={$point.c2},size={$expr.val},style={$style.text})
	|	^('circle' ID ^(POSITION point) ^(RADIUS expr) style?) 
	   {
	     $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
	     var.put("cx",$point.c1);
	     var.put("cy",$point.c2);
	     var.put("r",$expr.val);
	   }
	   -> circle(id={$ID.text},cx={$point.c1},cy={$point.c2},r={$expr.val},style={$style.text})
	|	^('rect' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("height",$v.val);
       var.put("width",$h.val);
     }
     -> rect(id={$ID.text},x={$point.c1},y={$point.c2},width={$h.val},height={$v.val},style={$style.text}) 
	|  ^('ellipse' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("cx",$point.c1);
       var.put("cy",$point.c2);
       var.put("rx",$h.val);
       var.put("ry",$v.val); 
	   }   
	   -> ellipse(id={$ID.text},cx={$point.c1},cy={$point.c2},rx={$h.val},ry={$v.val},style={$style.text})
	|	^('star' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?) {String path=getStarPath($point.c1,$point.c2,$r.val,$n.val);} 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("r",$r.val);
       var.put("nvert",$n.val);
     }
     
	   -> star(id={$ID.text},path={path},style={$style.text}) 
	| ^('polreg' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?) {String path=getPolygonPath($point.c1,$point.c2,$r.val,$n.val);}
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("r",$r.val);
       var.put("nvert",$n.val);
     }
	     
	   -> polreg(id={$ID.text},path={path},style={$style.text})
	|	^('container' ID ^(POSITION point) (containerdefs+=containerrow)*)
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       HashMap<String, Object> c = initContainer($id);
       System.out.println($containerdefs);
     }
	| ^(('style'|'nfstyle') ID styledef) -> 
	;
	
containerrow :	^(ROW innerdef comment?) | ^(ROW comment);

innerdef returns [String id]:
    def {$id=$def.id;}
  | ^(ID ID ^(POSITION point) ^(SCALE FLOAT) ^(ANGLE FLOAT));
	
style	:	styledef | ID;

styledef 	:	^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?) -> styledef(color={$fc.text},bordercolor={$bc.text},width={$INT.text}) ;
	
point returns [int c1, int c2]	:	expr1=expr expr2=expr { try{$c1=$expr1.val.intValue(); $c2=$expr2.val.intValue();}catch(NumberFormatException e){}} 
-> template(c1={$expr1.val.intValue()},c2={$expr2.val.intValue()}) "<c1> <c2> "
;

pathel	:	^(MOVETO ^(POSITION point)) -> template(p={$point.text}) "M <p> "
	|	^(LINETO ^(POSITION point)) -> template(p={$point.text}) "L <p> "
	|	CLOSE -> template() "Z"
	|	^(HORIZONTALLINE expr) -> template(c={$expr.val}) "H <c> "
	|	^(VERTICALLINE expr) -> template(c={$expr.val}) "V <c> "
	|	^(BEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ^(CONTROLPOINT p3=point) ) -> template(p1={$p1.text},p2={$p2.text},p3={$p3.text}) "C <p1> <p2> <p3> " 
	|	^(SHORTHANDBEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ) -> template(p1={$p1.text},p2={$p2.text}) "S <p1> <p2> "
	|	^(SHORTHANDQUADRATICBEZIER ^(CONTROLPOINT points+=point) (^(CONTROLPOINT points+=point))* ) -> template(points={$points}) "T <points>"
	|	^(QUADRATICBEZIER ^(CONTROLPOINT points+=point) (^(CONTROLPOINT points+=point))+ ) -> template(points={$points}) "T <points>"
	;

color	:	COLORNAME|HEXNUMBER;



expr returns [Double val] :	^('+' e1=expr e2=expr) {$val=$e1.val+$e2.val;}
  |^('-' e1=expr e2=expr) {$val=$e1.val-$e2.val;}
	|	term {$val=$term.val;};

term returns [Double val]:	^('*' t1=term t2=term) {$val=$t1.val*$t2.val;}
  | ^('/' t1=term t2=term) {$val=$t1.val/$t2.val;}
	|	atom {$val=$atom.val;};

atom returns [Double val] :
  	signedint 
  	{
      $val = Double.parseDouble($signedint.st.toString());
  	}
  | ^(MATH expr)
    {
      $val = $expr.val;
    }
  | ^(ID IDATTRIB) 
    {
      $val = 0.0;
      try{
         $val = vars.get($ID.text).get($IDATTRIB.text).doubleValue();
      } catch(Exception e){
        //e.printStackTrace();
      }
    }
  ;
    
signedint : (sign='+'|sign='-')?INT -> template(sign={$sign},int={$INT}) "<if(sign)><sign><endif><int>";


