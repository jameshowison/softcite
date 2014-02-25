package edu.utexas.ischool.jhowison;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;



/**
 * Unit test for simple App.
 */
public class AppTest 
    extends TestCase
{
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public AppTest( String testName )
    {
        super( testName );
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite()
    {
        return new TestSuite( AppTest.class );
    }

    /**
     * Rigourous Test :-)
     */
    public void testApp()
    {
        assertTrue( true );
    }

	public void testTTLFileLoad() throws Exception
	{
		TTLRepository testRepo = new TTLRepository();
		assertThat(testRepo, instanceOf(TTLRepository.class) );
	}
	
	public void testNumberOfPublications()
	{
		TTLRepository testRepo = new TTLRepository();
		assertEquals(TTLRepository.getNumberPublications(),90);
	}
}
