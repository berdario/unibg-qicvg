import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.TokenRewriteStream;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeAdaptor;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.antlr.runtime.tree.TreeRewriter;
import org.antlr.stringtemplate.StringTemplateGroup;


public class ExampleRunner {

	/**
	 * @param args
	 * @throws IOException 
	 * @throws RecognitionException 
	 */
	public static void main(String[] args) throws IOException, RecognitionException {
		qicvgLexer lex = new qicvgLexer(new ANTLRFileStream("test"+File.separator+"test1.txt","UTF8"));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		qicvgParser parser = new qicvgParser(tokens);
		
		//parser.setTreeAdaptor(new CommonTreeAdaptor());
		qicvgParser.prog_return ret = parser.prog();
		CommonTree tree = (CommonTree) ret.getTree();
		if (ret.tree != null) { // needed when the input is empty
			System.out.println("AST generato:");
			System.out.println(tree.toStringTree());

			CommonTreeNodeStream aststream = new CommonTreeNodeStream(tree);
			aststream.setTokenStream(tokens);
			unroller unrollwalker = new unroller(aststream);
			
			tree = (CommonTree) unrollwalker.prog(3,parser.containers).getTree();
			
			System.out.println("AST unrolled:");
			System.out.println(tree.toStringTree());

			aststream = new CommonTreeNodeStream(tree);
			aststream.setTokenStream(tokens);
			
			qicvgwalker walker = new qicvgwalker(aststream);
			
			FileReader templateFile = new FileReader("src" + File.separator + "qicvgwalker.stg");
			StringTemplateGroup templates = new StringTemplateGroup(templateFile);
			templateFile.close();
			walker.setTemplateLib(templates);
			
			qicvgwalker.prog_return output = walker.prog();
			System.out.println("output:\n"+output.getTemplate());
			//System.out.println("\n"+tokens.toString());
			
		}

	}

}
