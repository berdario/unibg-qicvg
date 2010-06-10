tree grammar qicvgwalker;

options {
    tokenVocab=qicvg ; // reuse token types
    ASTLabelType=CommonTree; // $label will have type CommonTree
    output=template;
}

scope Scope {
  HashMap<String,HashMap<String,Number>> vars;
  HashMap<String, Style> styles;
}

@header{
  import java.util.HashMap;
}

@members{
   
  HashMap<String,HashMap<String,Object>> containerDefs = new HashMap<String,HashMap<String,Object>>(); 
  HashMap<String,Container> containers = new HashMap<String,Container>(); 
  
  HashMap<String,Number> initVar(HashMap<String,HashMap<String,Number>> vars, String id){
       if (vars.get(id) != null) {
         System.err.println("Warning: L'id "+id+ " è riferito a più oggetti, i riferimenti potrebbero non essere corretti ");//TODO recuperare riga
         
       }
       HashMap<String, Number> var = new HashMap<String, Number>();
       vars.put(id,var);
       return var;
  }
  
  HashMap<String,Object> initContainer(String id){
       if (containerDefs.get(id) != null) {
         //TODO throw eccezione
       }
       HashMap<String, Object> container = new HashMap<String, Object>();
       containerDefs.put(id,container);
       return container;
  }
  
  Style initStyle(HashMap<String, Style> styles, String id, String fillcolor, String bordercolor, int borderwidth){
      if (styles.get(id) != null){
         System.err.println("Warning : Sono presenti più dichiarazioni dello stile '" + id + "' verrà considerata l'ultima occorrenza ");
      }
      Style s = this.new Style(fillcolor, bordercolor, borderwidth);
      styles.put(id,s);
      return s;
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
    double intradius = radius/3;
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
  
  class Style{
    String fillcolor, bordercolor;
    int borderwidth;
    public Style(String fillcolor, String bordercolor, int borderwidth) {
      this.fillcolor = fillcolor;
      this.bordercolor = bordercolor;
      this.borderwidth = borderwidth;
    }
  }
  
  class Container{
    HashMap<String,HashMap<String,Number>> vars = new HashMap<String,HashMap<String,Number>>();
    HashMap<String, Style> styles = new HashMap<String, Style>();
  }
}

prog 	scope Scope;
  @init{
    $Scope::vars = new HashMap<String,HashMap<String,Number>>();
    $Scope::styles = new HashMap<String, Style>();
  }
  :	(rows+=row)* {containers.put("",new Container());} -> svgfile(rows={$rows});

row   : ^(ROW def comment?) -> row(def={$def.st},comment={$comment.st}) | ^(ROW comment) -> row(comment={$comment.st}); 

comment: ^(COMMENT COMMENTTEXT) -> template(c={$COMMENTTEXT.text}) "\<!--<c>--\>" ;

def returns [String id]:
  	^('line' ID ^(INITPOSITION p1=point) ^(FINALPOSITION p2=point) style?) 
  	 {
  	   $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
       var.put("x1",$p1.c1);
       var.put("y1",$p1.c2);
       var.put("x2",$p2.c1);
       var.put("y2",$p2.c2);
     }
  	 -> line(id={$ID.text},x1={$p1.c1},y1={$p1.c2},x2={$p2.c1},y2={$p2.c2},style={$style.st})
	|	^('path' ID ^(POSITION point) style? pathelements+=pathel*) 
	   -> path(id={$ID.text},point={$point.st},pathelements={$pathelements},style={$style.st})
	|	^('square' ID ^(POSITION point) ^(SIDELEN expr) style?) 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("size",$expr.val);
     }
	   -> square(id={$ID.text},x={$point.c1},y={$point.c2},size={$expr.val},style={$style.st})
	|	^('circle' ID ^(POSITION point) ^(RADIUS expr) style?) 
	   {
	     $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
	     var.put("cx",$point.c1);
	     var.put("cy",$point.c2);
	     var.put("r",$expr.val);
	   }
	   -> circle(id={$ID.text},cx={$point.c1},cy={$point.c2},r={$expr.val},style={$style.st})
	|	^('rect' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("height",$v.val);
       var.put("width",$h.val);
     }
     -> rect(id={$ID.text},x={$point.c1},y={$point.c2},width={$h.val},height={$v.val},style={$style.st}) 
	|  ^('ellipse' ID ^(POSITION point) ^(HORIZLEN h=expr) ^(VERTLEN v=expr) style?) 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
       var.put("cx",$point.c1);
       var.put("cy",$point.c2);
       var.put("rx",$h.val);
       var.put("ry",$v.val); 
	   }   
	   -> ellipse(id={$ID.text},cx={$point.c1},cy={$point.c2},rx={$h.val},ry={$v.val},style={$style.st})
	|	^('star' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?) {String path=getStarPath($point.c1,$point.c2,$r.val,$n.val);} 
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("r",$r.val);
       var.put("nvert",$n.val);
     }
     
	   -> star(id={$ID.text},path={path},style={$style.st}) 
	| ^('polreg' ID ^(POSITION point) ^(RADIUS r=expr) ^(VERTEXES n=expr) style?) {String path=getPolygonPath($point.c1,$point.c2,$r.val,$n.val);}
	   {
       $id=$ID.text;
       HashMap<String, Number> var = initVar($Scope::vars,$id);
       var.put("x",$point.c1);
       var.put("y",$point.c2);
       var.put("r",$r.val);
       var.put("nvert",$n.val);
     }
	     
	   -> polreg(id={$ID.text},path={path},style={$style.st})
	|
		^('container' 
     (
       ID ^(POSITION point) 
       {
          $id=$ID.text;
          HashMap<String, Number> var = initVar($Scope::vars,$id);
          var.put("x",$point.c1);
          var.put("y",$point.c2);
       } 
     ) containerblock )
     {
       HashMap<String, Object> c = initContainer($id);
     } -> template() "TODO container"
	| ^(('style'|'nfstyle') ID styledef)
	  {
	     $id=$ID.text;
       initStyle($Scope::styles,$id,$styledef.fillcolor,$styledef.bordercolor,$styledef.borderwidth);
	  } -> template() "" 
	;
	
containerblock
     scope Scope;
     @init {
        $Scope::vars = new HashMap<String,HashMap<String,Number>>();
        $Scope::styles = new HashMap<String,Style>();
     }
     :  (containerdefs+=containerrow)* {System.out.println($containerdefs);}
     ;
	
containerrow :	^(ROW innerdef comment?) | ^(ROW comment);

innerdef returns [String id]
  @after{
    /*System.out.println("variabili e stili nello scope corrente:");
    for (int s=$Scope.size()-1; s>=0; s--){
      System.out.println("livello "+s+": \nvars: "+$Scope[s]::vars+"\nstyles: "+$Scope[s]::styles);
    }*/
  }
  :
    def {$id=$def.id;}
  | ^(ID thisid=ID ^(POSITION point) ^(SCALE FLOAT) ^(ANGLE FLOAT))
    {
      HashMap<String, Number> var = initVar($Scope::vars,$thisid.text);
      var.put("x",$point.c1);
      var.put("y",$point.c2);
    }
  ;
	
style	:	styledef -> template(sdef={$styledef.st}) "<sdef>"
      | ID 
      {
        Style s = $Scope::styles.get($ID.text);
        if (s==null) {
                      
                      System.err.println("Lo style " +$ID.text+ " è stato richiamato senza essere dichiarato, verrà utilizzato lo stile di default");}
                      s= new Style("black","black",1);
      } ->  styledef(color={s.fillcolor},bordercolor={s.bordercolor},width={s.borderwidth})
      ;

styledef returns [String fillcolor, String bordercolor, int borderwidth]	
    :	^(STYLE (^(FILLCOLOR fc=color))? (^(BORDERCOLOR bc=color))? (^(BORDERWIDTH INT))?)
    {
        $fillcolor = $fc.text;
        $bordercolor = $bc.text;
        try{
          $borderwidth = new Integer($INT.text);
        } catch(NumberFormatException e){
          //it's fine to leave borderwidth undeclared 
        }
    }
    -> styledef(color={$fc.text},bordercolor={$bc.text},width={$INT.text}) ;
	
point returns [int c1, int c2]	:	expr1=expr expr2=expr { try{$c1=$expr1.val.intValue(); $c2=$expr2.val.intValue();}catch(NumberFormatException e){}} 
-> template(c1={$expr1.val.intValue()},c2={$expr2.val.intValue()}) "<c1> <c2> "
;

pathel	:	^(MOVETO ^(POSITION point)) -> template(p={$point.st}) "M <p> "
	|	^(LINETO ^(POSITION point)) -> template(p={$point.st}) "L <p> "
	|	CLOSE -> template() "Z"
	|	^(HORIZONTALLINE expr) -> template(c={$expr.val}) "H <c> "
	|	^(VERTICALLINE expr) -> template(c={$expr.val}) "V <c> "
	|	^(BEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ^(CONTROLPOINT p3=point) ) -> template(p1={$p1.st},p2={$p2.st},p3={$p3.st}) "C <p1> <p2> <p3> " 
	|	^(SHORTHANDBEZIER ^(CONTROLPOINT p1=point) ^(CONTROLPOINT p2=point) ) -> template(p1={$p1.st},p2={$p2.st}) "S <p1> <p2> "
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
      HashMap<String,Number> var = null;
      for (int s=$Scope.size()-1; s>=0 && var==null; s--){
        var = $Scope[s]::vars.get($ID.text);
      }
      try{
         Number value = var.get($IDATTRIB.text);
         try{
            $val = value.doubleValue();
         } catch (Exception e){
            //e.printStackTrace();
         }
      } catch(Exception e){
        System.err.println("tentativo di accedere all'attributo "+$IDATTRIB.text+" dell'oggetto "+$ID.text+" non andato a buon fine:");
        //e.printStackTrace();
      }
    }
  ;
    
signedint : (sign='+'|sign='-')?INT -> template(sign={$sign},int={$INT}) "<if(sign)><sign><endif><int>";


