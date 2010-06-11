import java.util.ArrayList;
import java.util.List;

import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.Tree;
import org.antlr.runtime.Token;

public class QicvgTree extends CommonTree {
	private static final long serialVersionUID = -57392655284067254L;

	private int line = 0;
	private int column = 0;

	public QicvgTree(){}
	
	public QicvgTree(Token t) {
		super(t);
		if (t != null) {
			line = t.getLine();
			column = t.getCharPositionInLine();
			
		}
	}
	
	public QicvgTree(QicvgTree node){
		super(node);
		this.childIndex = node.childIndex;
		this.parent = node.parent;
		if (node.children != null) {
			if (this.children == null){
				this.children = new ArrayList();
			}
			for (QicvgTree c : (ArrayList<QicvgTree>) node.children) {
				this.children.add(new QicvgTree(c));
			}
		}
	}
	
	public Tree dupNode() {
		return new QicvgTree(this);
	}

	public int getLine() {
		return line;
	}

	public int getColumn() {
		return column;
	}
}
