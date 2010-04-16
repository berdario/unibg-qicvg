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
	
	ArrayList<String> files = new ArrayList<String>();
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
		for (int i=1;i<8;i++){
			files.add("test"+i+".txt");
		}
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testQicvgLexer() throws IOException{
		for (String f : files){
			qicvgLexer lex = new qicvgLexer(new ANTLRFileStream(f,"UTF8"));
			CommonTokenStream tokens = new CommonTokenStream(lex);
			System.out.println(f+":\n"+tokens.getTokens());
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
