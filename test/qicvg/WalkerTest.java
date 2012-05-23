package qicvg;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;
import org.antlr.runtime.RecognitionException;
import org.antlr.runtime.tree.CommonTree;

import org.junit.BeforeClass;
import org.junit.experimental.theories.DataPoints;
import org.junit.experimental.theories.Theories;
import org.junit.experimental.theories.Theory;
import org.junit.runner.RunWith;

@RunWith(Theories.class)
public class WalkerTest {

	@DataPoints
	public static String[] files() throws Exception {
		ArrayList<String> fileList = new ArrayList<>();
		String testdir = "test" + File.separator;
		File currentDirectory = new File(testdir);
		System.out.println(currentDirectory.getAbsolutePath());
		for (String fn : currentDirectory.list()) {
			if (fn.endsWith(".txt") && !fn.endsWith(".fail.txt")) {
				fileList.add(testdir + fn);
			}
		}
		return fileList.toArray(new String[0]);
	}
	
	@DataPoints
	public static String[] failFiles() throws Exception {
		ArrayList<String> failFileList = new ArrayList<>();
		String testdir = "test" + File.separator;
		File currentDirectory = new File(testdir);
		System.out.println(currentDirectory.getAbsolutePath());
		for (String fn : currentDirectory.list()) {
			if (fn.endsWith(".fail.txt")) {
				failFileList.add(testdir + fn);
			}
		}
		return failFileList.toArray(new String[0]);
	}

	@Theory
	public void testQicvgwalker(String file) throws IOException {

		qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(file, "UTF8"));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		qicvgParser parser = new qicvgParser(tokens);
		try {
			parser.setTreeAdaptor(new QicvgTreeAdaptor());
			qicvgParser.prog_return ret = parser.prog();
			CommonTree tree = (CommonTree) ret.getTree();
			if (tree != null) { // needed when the input is empty
				// System.out.println(tree.toStringTree());

				QicvgWalker walker = new QicvgWalker(new QicvgTreeNodeStream(
						tree), (new Main()).getTemplates());
				walker.walk(3);
			}
		} catch (RecognitionException e) {
			fail("Errore inaspettato nel parsing di " + file);
		}
		assertTrue("Errore inaspettato nel parsing di " + file, parser
				.getExceptions().size() == 0);
		// assertTrue("Errore inaspettato nel lexing di "+f,
		// lex.getExceptions().size()==0 );
	}

	@Theory
	public void testQicvgParserFail(String file) throws IOException {

		qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(file, "UTF8"));
		CommonTokenStream tokens = new CommonTokenStream(lex);
		qicvgParser parser = new qicvgParser(tokens);
		try {
			// assertTrue("Riconoscimento invalido nel lexing di "+f,
			// lex.getExceptions().size()==0 );
			(new QicvgWalker(new QicvgTreeNodeStream(parser.prog().getTree()),
					(new Main()).getTemplates())).walk(3);
			fail("Riconoscimento invalido delle produzioni in " + file);
		} catch (RecognitionException e) {
		}

	}

}
