import static org.junit.Assert.*;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import org.antlr.runtime.ANTLRFileStream;
import org.antlr.runtime.CommonTokenStream;

public class LexerTest {
	
	static ArrayList<String> files = new ArrayList<String>(), failFiles = new ArrayList<String>();
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		File currentDirectory = new File(".");
		for (String fn : currentDirectory.list()){
			if (fn.endsWith(".fail.txt")){
				failFiles.add(fn);
			}
			else if (fn.endsWith(".txt")){
				files.add(fn);
			}
		}
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testQicvgLexer() throws IOException{
		for (String f : files){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			tokens.getTokens();
			assertTrue("Errore inaspettato nel lexing di "+f, lex.getExceptions().size()==0 );
		}
		for (String f : failFiles){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			tokens.getTokens();
			assertTrue("Riconoscimento invalido dei token in "+f, lex.getExceptions().size()>0 );
		}
	}

	@Test
	public void testQicvgLexerCharStream() {
		fail("Not yet implemented");
	}

	@Test
	public void testQicvgLexerCharStreamRecognizerSharedState() {
		fail("Not yet implemented");
	}

	@Test
	public void testGetGrammarFileName() {
		fail("Not yet implemented");
	}

}
