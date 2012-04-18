
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.CommonTreeAdaptor;
import org.antlr.runtime.tree.CommonTreeNodeStream;
import org.junit.BeforeClass;
import org.junit.Test;

import qicvg.qicvgLexer;
import qicvg.qicvgParser;


public class WalkerTest {
	
	static ArrayList<String> files = new ArrayList<String>();


	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		String testdir = "test" + File.separator;
		File currentDirectory = new File(testdir);
		System.out.println(currentDirectory.getAbsolutePath());
		for (String fn : currentDirectory.list()){
			if ((fn.endsWith(".txt") && !(fn.endsWith(".failL.txt")) && !(fn.endsWith(".failP.txt")))){
				files.add(testdir + fn);
			}
		}
	}
	
	@Test
	public void testQicvgwalker() throws IOException{
		for (String f : files){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			qicvgParser parser = new qicvgParser(tokens);
			try {
				parser.setTreeAdaptor(new CommonTreeAdaptor());
				qicvgParser.prog_return ret = parser.prog();
				CommonTree tree = (CommonTree) ret.getTree();
				if (ret.tree != null) { //needed when the input is empty
					System.out.println(tree.toStringTree());

					//QicvgWalker walker = new QicvgWalker(new CommonTreeNodeStream(tree));
					//walker.prog();
				}
			} catch (RecognitionException e) {
				fail("Errore inaspettato nel parsing di "+f);
			}
			assertTrue("Errore inaspettato nel parsing di "+f, parser.getExceptions().size()==0 );
			//TODO ripristinare rilevamento eccezioni
			//assertTrue("Errore inaspettato nel lexing di "+f, lex.getExceptions().size()==0 );
		}
	}

}
