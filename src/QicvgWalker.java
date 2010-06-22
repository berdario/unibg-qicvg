import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Stack;

import org.antlr.stringtemplate.StringTemplateGroup;

import static java.lang.Math.cos;
import static java.lang.Math.sin;

public class QicvgWalker {
	QicvgTreeNodeStream stream;
	StringTemplateGroup templates;
	ArrayList<String> tokenNames;
	QicvgTree tree;
	HashMap<String,Def> defs = new HashMap<String,Def>();
	HashMap<String, Style> styles = new HashMap<String, Style>();
	HashMap<String,Container> containers = new HashMap<String,Container>();
	Stack<HashMap<String,Def>> currentBlock = new Stack<HashMap<String,Def>>();
	Integer maxRecursion = null;

	
	QicvgWalker(QicvgTreeNodeStream stream, StringTemplateGroup templates){
		this.stream = stream;
		this.templates = templates;
		tokenNames = new ArrayList<String>(Arrays.asList(qicvgParser.tokenNames));
	}
	
	Def initDef(HashMap<String,Def> defs, String id, String templatename){
	       if (defs.get(id) != null) {
	         System.out.println("id trovato: "+id);//TODO recuperare riga
	         
	       }
	       Def def = new Def(templatename);
	       defs.put(id,def);
	       return def;
	}
	
	void initContainer(HashMap<String,Container> containers, String id, Container container){
	       if (containers.get(id) != null) {
	         //TODO throw eccezione
	       }
	       containers.put(id,container);
	  }
	
	void initStyle(HashMap<String, Style> styles, String id, Style s){
	      if (styles.get(id) != null){
	         //TODO throw eccezione
	      }
	      styles.put(id,s);
	}
	
	String walk(int maxRecursion){
		this.maxRecursion = maxRecursion;
		QicvgTree tree = (QicvgTree) stream.getTreeSource();
		if (tree.isNil()){
			ArrayList<String> result = new ArrayList<String>();
			ArrayList<QicvgTree> children = (ArrayList<QicvgTree>) tree.getChildren();
			for (QicvgTree child : children){
				result.add((String) child.accept(this));
			}
			;
			
			return templates.getInstanceOf("svgfile", new STAttrMap().put("rows",result)).toString();
		} else{
			System.err.println("this shouldn't happen");
			return null;
		}
	}
	
	String visit(QicvgTree t) {
		
		int type = t.getType();
			if (type == qicvgParser.COMMENT){
				return templates.getInstanceOf("comment",
						new STAttrMap().put("comment", t.getChild(0))
						).toString();
			} else if (type == tokenNames.indexOf("'line'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id,"line");
				def.vars.put("x",(new Expr(t.getChild(1).getChild(0))).accept(this));
				def.vars.put("y",(new Expr(t.getChild(1).getChild(1))).accept(this));
				def.vars.put("x2",(new Expr(t.getChild(2).getChild(0))).accept(this));
				def.vars.put("y2",(new Expr(t.getChild(2).getChild(1))).accept(this));
			    String style = getStyle(t.getChild(3),id);
				return templates.getInstanceOf("line",
						new STAttrMap().put(
								"id", id).put(
								"x", def.vars.get("x")).put(
								"y", def.vars.get("y")).put(
								"x2", def.vars.get("x2")).put(
								"y2", def.vars.get("y2")).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'path'")){
				ArrayList<QicvgTree> children = (ArrayList<QicvgTree>) t.getChildren();
				String id = children.get(0).toString();
				ArrayList<String> pathelements = new ArrayList<String>();
				int index = 2;
				String style = null;
				try{
					if (children.get(2).getType() == qicvgParser.STYLE
						|| children.get(2).getType() == qicvgParser.ID ){
						index = 3;
						style = getStyle(children.get(2),id);
					}
				}catch (IndexOutOfBoundsException e) {
					//ok to ignore
				}
				for (QicvgTree child : children.subList(index, children.size())){
					pathelements.add((String)child.accept(this)+" ");
				}
				return templates.getInstanceOf("path",
						new STAttrMap().put(
								"id", id).put(
								"point", children.get(1).accept(this)).put(
								"style", style).put(
								"pathelements", pathelements)
						).toString();
			} else if (type == tokenNames.indexOf("'square'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id,"square");
				def.vars.put("x",(new Expr(t.getChild(1).getChild(0))).accept(this));
			    def.vars.put("y",(new Expr(t.getChild(1).getChild(1))).accept(this));
			    def.vars.put("width",(new Expr(t.getChild(2).getChild(0))).accept(this));
			    String style = getStyle(t.getChild(3),id);
				return templates.getInstanceOf("square",
						new STAttrMap().put(
								"id", id).put(
								"x", def.vars.get("x")).put(
								"y", def.vars.get("y")).put(
								"width", def.vars.get("width")).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'circle'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id,"circle");
				def.vars.put("cx",(new Expr(t.getChild(1).getChild(0))).accept(this));
				def.vars.put("cy",(new Expr(t.getChild(1).getChild(1))).accept(this));
				def.vars.put("r",(new Expr(t.getChild(2).getChild(0))).accept(this));
			    String style = getStyle(t.getChild(3),id);
				return templates.getInstanceOf("circle",
						new STAttrMap().put(
								"id", id).put(
								"cx", def.vars.get("cx")).put(
								"cy", def.vars.get("cy")).put(
								"r", def.vars.get("r")).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'rect'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id,"rect");
				def.vars.put("x",(new Expr(t.getChild(1).getChild(0))).accept(this));
				def.vars.put("y",(new Expr(t.getChild(1).getChild(1))).accept(this));
				def.vars.put("height",(new Expr(t.getChild(2).getChild(0))).accept(this));
				def.vars.put("width",(new Expr(t.getChild(3).getChild(0))).accept(this));
			    String style = getStyle(t.getChild(4),id);
				return templates.getInstanceOf("rect",
						new STAttrMap().put(
								"id", id).put(
								"x", def.vars.get("x")).put(
								"y", def.vars.get("y")).put(
								"height", def.vars.get("height")).put(
								"width", def.vars.get("width")).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'ellipse'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id,"ellipse");
				def.vars.put("cx",(new Expr(t.getChild(1).getChild(0))).accept(this));
				def.vars.put("cy",(new Expr(t.getChild(1).getChild(1))).accept(this));
				def.vars.put("rx",(new Expr(t.getChild(2).getChild(0))).accept(this));
				def.vars.put("ry",(new Expr(t.getChild(3).getChild(0))).accept(this));
			    String style = getStyle(t.getChild(4),id);
				return templates.getInstanceOf("ellipse",
						new STAttrMap().put(
								"id", id).put(
								"cx", def.vars.get("cx")).put(
								"cy", def.vars.get("cy")).put(
								"rx", def.vars.get("rx")).put(
								"ry", def.vars.get("ry")).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'star'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id,"star");
				def.vars.put("x",(new Expr(t.getChild(1).getChild(0))).accept(this));
				def.vars.put("y",(new Expr(t.getChild(1).getChild(1))).accept(this));
				def.vars.put("r",(new Expr(t.getChild(2).getChild(0))).accept(this));
				def.vars.put("nvert",(new Expr(t.getChild(3).getChild(0))).accept(this));
			    String style = getStyle(t.getChild(4),id);
				return templates.getInstanceOf("star",
						new STAttrMap().put(
								"id", id).put(
								"path", getStarPath(
										def.vars.get("x").doubleValue(),
										def.vars.get("y").doubleValue(),
										def.vars.get("r").doubleValue(),
										def.vars.get("nvert").doubleValue()
										)).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'polreg'")){
				String id = t.getChild(0).toString();
				Def def = initDef(defs,id, "polreg");
				def.vars.put("x",(new Expr(t.getChild(1).getChild(0))).accept(this));
				def.vars.put("y",(new Expr(t.getChild(1).getChild(1))).accept(this));
				def.vars.put("r",(new Expr(t.getChild(2).getChild(0))).accept(this));
				def.vars.put("nvert",(new Expr(t.getChild(3).getChild(0))).accept(this));
			    String style = getStyle(t.getChild(4),id);
				return templates.getInstanceOf("star",
						new STAttrMap().put(
								"id", id).put(
								"path", getPolygonPath(
										def.vars.get("x").doubleValue(),
										def.vars.get("y").doubleValue(),
										def.vars.get("r").doubleValue(),
										def.vars.get("nvert").doubleValue()
										)).put(
								"style", style)
						).toString();
			} else if (type == tokenNames.indexOf("'style'") || type == tokenNames.indexOf("'nfstyle'")){
				String id = t.getChild(0).toString();
				initStyle(styles, id, (new IdReference(t.getChild(1))).accept(this));
				return null;
			} else if (type == tokenNames.indexOf("'container'")){
				String id = t.getChild(0).toString();
				double x = (new Expr(t.getChild(1).getChild(0))).accept(this);
				double y = (new Expr(t.getChild(1).getChild(1))).accept(this);
				Def def = initDef(defs,id,null);
				def.vars.put("x",x);
				def.vars.put("y",y);
				ContainerBlock block = new ContainerBlock();
				block.addChildren(t.getChildren().subList(2, t.getChildCount()));
			    initContainer(containers, id, (Container)block.accept(this) );
			    return unroll(id,x,y);
			} else if (type == qicvgParser.ID){
				Style s = styles.get(t.toString());
				return templates.getInstanceOf("styledef",
						new STAttrMap().put(
								"color", s.fillcolor).put(
								"bordercolor", s.bordercolor).put(
								"width", s.borderwidth)
						).toString();
			} else if (type == qicvgParser.POSITION || type == qicvgParser.CONTROLPOINT ){
				return t.getChild(0)+" "+t.getChild(1);
			} else if (type == qicvgParser.MOVETO){
				return "M "+t.getChild(0).accept(this)+" ";
			} else if (type == qicvgParser.LINETO){
				return "L "+t.getChild(0).accept(this)+" ";
			} else if (type == qicvgParser.CLOSE){
				return "Z";
			} else if (type == qicvgParser.HORIZONTALLINE){
				return "H "+(new Expr(t.getChild(0))).accept(this)+" ";
			} else if (type == qicvgParser.VERTICALLINE){
				return "V "+(new Expr(t.getChild(0))).accept(this)+" ";
			} else if (type == qicvgParser.BEZIER){
				return templates.getInstanceOf("bezier",
						new STAttrMap().put(
								"p1", t.getChild(0).accept(this)).put(
								"p2", t.getChild(1).accept(this)).put(
								"p3", t.getChild(2).accept(this))
						).toString();
			} else if (type == qicvgParser.SHORTHANDBEZIER){
				return templates.getInstanceOf("shorthandbezier",
						new STAttrMap().put(
								"p1", t.getChild(0).accept(this)).put(
								"p2", t.getChild(1).accept(this))
						).toString();
			} else if (type == qicvgParser.SHORTHANDQUADRATICBEZIER){
				ArrayList<QicvgTree> children = (ArrayList<QicvgTree>) t.getChildren();
				ArrayList<String> result = new ArrayList<String>();
				for (QicvgTree child: children){
					result.add((String) child.accept(this)+" ");
				}
				return templates.getInstanceOf("shorthandquadraticbezier",
						new STAttrMap().put(
								"points", result)
						).toString();
			} else if (type == qicvgParser.QUADRATICBEZIER){
				ArrayList<QicvgTree> children = (ArrayList<QicvgTree>) t.getChildren();
				ArrayList<String> result = new ArrayList<String>();
				for (QicvgTree child: children){
					result.add((String) child.accept(this)+" ");
				}
				return templates.getInstanceOf("quadraticbezier",
						new STAttrMap().put(
								"points", result)
						).toString();
			}
			return null;
	}
	
	Style visit (IdReference t){ //style reference to ID
		int type = t.getType();
		if (type == qicvgParser.STYLE){
				Integer borderwidth = null;
				String fillcolor = null, bordercolor = null;
				try{
					fillcolor = t.getFirstChildWithType(qicvgParser.FILLCOLOR).getChild(0).toString();
				} catch (NullPointerException e){
					//no fillcolor?
				}
				try{
					bordercolor = t.getFirstChildWithType(qicvgParser.BORDERCOLOR).getChild(0).toString();
				} catch (NullPointerException e){
					//no bordercolor?
				}
				try{
					borderwidth = new Integer(t.getFirstChildWithType(qicvgParser.BORDERWIDTH).getChild(0).toString());
				} catch(NumberFormatException e){
			          //it's fine to leave borderwidth undeclared 
		        }
				return new Style(fillcolor, bordercolor, borderwidth );
			}
		System.err.println("this shouldn't happen");
		return null;
	}
	
	Double visit (Expr t){
		int type = t.getType();
		if (type == qicvgParser.MATH){
			return (new Expr(t.getChild(0))).accept(this); 
		} else if (t.getType() == qicvgParser.INT){
			return new Double(t.toString());
		} else if ((type == tokenNames.indexOf("'+'") || (type == tokenNames.indexOf("'-'")))
						&& t.getChild(0).getType() == qicvgParser.INT ){
			return new Double(t.toString()+t.getChild(0).toString());
		} else if (type == tokenNames.indexOf("'+'")){
			return (new Expr(t.getChild(0))).accept(this)+(new Expr(t.getChild(1))).accept(this);
		} else if (type == tokenNames.indexOf("'-'")){
			return (new Expr(t.getChild(0))).accept(this)-(new Expr(t.getChild(1))).accept(this);
		} else if (type == tokenNames.indexOf("'*'")){
			return (new Expr(t.getChild(0))).accept(this)*(new Expr(t.getChild(1))).accept(this);
		} else if (type == tokenNames.indexOf("'/'")){
			return (new Expr(t.getChild(0))).accept(this)/(new Expr(t.getChild(1))).accept(this);
		} else if (type == qicvgParser.ID){ //reference to IDATTRIB
			return defs.get(t.toString()).vars.get(t.getChild(0).toString()).doubleValue(); 
		}
		System.err.println("this shouldn't happen");
		return null;
	}
	
	Container visit (ContainerBlock t){
		ArrayList<ContainerBlock> children = (ArrayList<ContainerBlock>) t.getChildren();
		Container container = new Container();
		String id;
		int type;
		for (QicvgTree child : children){
			type = child.getType();
			if (type != qicvgParser.COMMENT) {
				if (type == qicvgParser.ID) {
					id = child.getChild(0).toString();
					Def d = new Def("recursion"); // TODO sarebbe meglio usare l'id del container
					d.vars.put("x", (new Expr(child.getChild(1).getChild(0)))
							.accept(this));
					d.vars.put("y", (new Expr(child.getChild(1).getChild(1)))
							.accept(this));
					d.vars.put("scale", new Double(child.getChild(2)
							.getChild(0).toString()));
					d.vars.put("angle", new Double(child.getChild(3)
							.getChild(0).toString()));
					container.defs.put(id, d);
				} else if (type == tokenNames.indexOf("'style'")
						|| type == tokenNames.indexOf("'nfstyle'")) {
					child.accept(this);
					id = child.getFirstChildWithType(qicvgParser.ID).toString();
					container.styles.put(id, styles.get(id));
				} else {
					child.accept(this);
					id = child.getFirstChildWithType(qicvgParser.ID).toString();
					container.defs.put(id, defs.get(id));
				}
				container.idlist.add(id);
			}
		}
		return container;
	}
	
	String getStyle(QicvgTree t, String id){
		try{
			if (t.getType() == qicvgParser.ID){
				//TODO sistemare
				defs.get(id).style=styles.get(t.toString());
				return (String) t.accept(this);
			} else if (t.getType() == qicvgParser.STYLE){
				Style style = (new IdReference(t)).accept(this);
				defs.get(id).style = style;
				return templates.getInstanceOf("styledef",
						new STAttrMap().put(
								"color", style.fillcolor).put(
								"bordercolor", style.bordercolor).put(
								"width", style.borderwidth)
						).toString();
			}
		}catch(NullPointerException e){
			//non-existant style?
		}
		return null;
	}
	
	public String unroll(String containerid, double x, double y){
		Container c = containers.get(containerid);
		currentBlock.push(transform(c.defs,x,y,1,0));
		String result=unroll(containerid);
		currentBlock.pop();
		return result;
	}
	
	public String unroll(String containerid){
		if (currentBlock.size() >= maxRecursion){
			return "";
		}
		Container c = containers.get(containerid);
		String result="";
		Def currentElement;
		for (String id : c.idlist){
			currentElement = currentBlock.peek().get(id);
			if (!currentElement.templatename.equals("recursion")){
				result += applyTemplate(currentElement);
			} else{
				currentBlock.push(transform(currentBlock.peek(),
						currentElement.vars.get("x").doubleValue(),
						currentElement.vars.get("y").doubleValue(),
						currentElement.vars.get("scale").doubleValue(),
						currentElement.vars.get("angle").doubleValue()));
				result += unroll(containerid);
				currentBlock.pop();
			}
		}
		return result;
	}
	
	HashMap<String,Def> transform(HashMap<String,Def> in, double dx, double dy, double scale, double angle){
		HashMap<String,Def> out = new HashMap<String, Def>(in);
		for (String id : out.keySet()){
			Def olddef = out.get(id);
			Def newdef = new Def(olddef.templatename);
			newdef.style = olddef.style;
			Number x,y,x2,y2,cx,cy;
			x = olddef.vars.get("x");
			y = olddef.vars.get("y");
			x2 = olddef.vars.get("x2");
			y2 = olddef.vars.get("y2");
			cx = olddef.vars.get("cx");
			cy = olddef.vars.get("cy");
			ArrayList<Double> point;
			if (x != null && y != null){
				point = rotate(dx,dy,x.doubleValue()+dx,y.doubleValue()+dy,angle);
				newdef.vars.put("x",point.get(0)*scale);
				newdef.vars.put("y",point.get(1)*scale);
			}
			if (x2 != null && y2 != null){
				point = rotate(dx,dy,x2.doubleValue()+dx,y2.doubleValue()+dy,angle);
				newdef.vars.put("x2",point.get(0)*scale);
				newdef.vars.put("y2",point.get(1)*scale);
			}
			if (cx != null && cy != null){
				point = rotate(dx,dy,cx.doubleValue()+dx,cy.doubleValue()+dy,angle);
				newdef.vars.put("cx",point.get(0)*scale);
				newdef.vars.put("cy",point.get(1)*scale);
			}
			
			Number height,width,r,rx,ry;
			height = olddef.vars.get("height");
			width = olddef.vars.get("width");
			r = olddef.vars.get("r");
			rx = olddef.vars.get("rx");
			ry = olddef.vars.get("ry");
			if (height != null && width != null){
				newdef.vars.put("height",height.doubleValue()*scale);
				newdef.vars.put("width",width.doubleValue()*scale);
			} else if(width != null){
				newdef.vars.put("width",width.doubleValue()*scale);
			}
			if (r != null){
				newdef.vars.put("r",r.doubleValue()*scale);
			}
			if (rx != null && ry != null){
				newdef.vars.put("rx",rx.doubleValue()*scale);
				newdef.vars.put("ry",ry.doubleValue()*scale);
			}
			
			newdef.vars.put("angle",olddef.vars.get("angle"));
			newdef.vars.put("scale",olddef.vars.get("scale"));
			
			out.put(id,newdef);
		}
		return out;
	}
	
	ArrayList<Double> rotate(double x1, double y1, double x2, double y2, double angle){
	    ArrayList<Double> result = new ArrayList<Double>();
	    result.add( x2* cos(angle)+ y2* sin(angle)+x1- x1* cos(angle)- y1* sin(angle));
	    result.add( y2* cos(angle)- x2* sin(angle)+y1+ x1* sin(angle)- y1* cos(angle));
	    return result;
	  }
	
	String applyTemplate(Def def){
		String stylestring = null;
		try{
			stylestring = templates.getInstanceOf("styledef",
				new STAttrMap().put(
						"color", def.style.fillcolor).put(
						"bordercolor", def.style.bordercolor).put(
						"width", def.style.borderwidth)
				).toString();
		} catch (NullPointerException e){
			//no style
		}
		STAttrMap templateMap = new STAttrMap();
		templateMap.putAll(def.vars);
		templateMap.put("style", stylestring);
		return templates.getInstanceOf(def.templatename, templateMap).toString();
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

	public static class STAttrMap extends HashMap {
	      public STAttrMap put(String attrName, Object value) {
	        super.put(attrName, value);
	        return this;
	      }
	      public STAttrMap put(String attrName, int value) {
	        super.put(attrName, new Integer(value));
	        return this;
	      }
	}
	
	class Container{
	    HashMap<String,Def> defs = new HashMap<String,Def>();
	    HashMap<String, Style> styles = new HashMap<String, Style>();
	    ArrayList<String> idlist = new ArrayList<String>();
	    //HashMap<String,Container> containers = new HashMap<String,Container>();
	}
	
	class Def{
		String templatename;
		HashMap<String,Number> vars = new HashMap<String, Number>();
		Style style = null;
		
		public Def(String templatename) {
			this.templatename = templatename;
		}
	}
}
