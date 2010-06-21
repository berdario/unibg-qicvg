
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeNodeStream;

public class QicvgTreeNodeStream extends CommonTreeNodeStream {

	public QicvgTreeNodeStream(Object tree) {
		super(tree);
	}
	
	public QicvgTree LT(int k){
		try{
			return new QicvgTree((CommonTree)super.LT(k));
		} catch(NullPointerException e){
			return (QicvgTree) super.LT(k);
		}
	}

}
