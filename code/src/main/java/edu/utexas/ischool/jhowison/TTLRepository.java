package edu.utexas.ischool.jhowison;
/**********************************************************
Classpath must include these .jars (everything in $JENAROOT/lib/):

$JENAROOT/lib/commons-codec-1.5.jar:$JENAROOT/lib/httpclient-4.1.2.jar:$JENAROOT/lib/httpcore-4.1.3.jar:$JENAROOT/lib/icu4j-3.4.4.jar:$JENAROOT/lib/jena-arq-2.9.0-incubating.jar:$JENAROOT/lib/jena-core-2.7.0-incubating.jar:$JENAROOT/lib/jena-iri-0.9.0-incubating.jar:$JENAROOT/lib/log4j-1.2.16.jar:$JENAROOT/lib/slf4j-api-1.6.4.jar:$JENAROOT/lib/slf4j-log4j12-1.6.4.jar:$JENAROOT/lib/xercesImpl-2.10.0.jar:$JENAROOT/lib/xml-apis-1.4.01.jar:.

***********************************************************/

import java.io.*;
import java.util.*;
import java.net.URL;

import com.hp.hpl.jena.*;
import com.hp.hpl.jena.util.*;
import com.hp.hpl.jena.rdf.model.*;
import com.hp.hpl.jena.query.*;

import com.hp.hpl.jena.sparql.*;
import com.hp.hpl.jena.sparql.engine.*;



public class TTLRepository {
	
	public static Model model;
	
	public TTLRepository() {
		//
		
//		Class myClass = this.getClass();
//		URL fileURL =  myClass.getResource("testdata/SoftwareCitationDataset.ttl");
//		URL fileURL =  myClass.getClassLoader().getResource("testToLoad.txt");
//		String myPath = fileURL.getPath();  // this is throwing an NPE.
//		Model model = FileManager.get().loadModel(myPath);
		
		this.model = FileManager.get().loadModel(
//			"https://raw.github.com/jameshowison/softcite/master/data/SoftwareCitationDataset.ttl"
			"/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/data/SoftwareCitationDataset.ttl" 
		);
		
		if (this.model == null) {
			throw new IllegalArgumentException(
			"ttl file not found");
		}
	}
	
	public Model getModel() {
		return this.model;
	}
	
	public static int getNumberPublications() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT (count(DISTINCT ?publication) AS ?pubCount)");
		queryStr.append("WHERE  {");
		queryStr.append("       ?publication rdf:type bioj:article .");
		queryStr.append("}");
		
		return queryReturnsSingleInt(queryStr, "pubCount");
	}
	
	public static int getNumberSelections() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT (COUNT(DISTINCT ?sel) as ?selectionCount)");
		queryStr.append("WHERE {");
		queryStr.append(" { ?article bioj:has_selection ?sel }");
		
		queryStr.append(" { ?article bioj:has_selection ?sel }");
	//	queryStr.append("	?article bioj:has_selection ?sel .");
		queryStr.append("}");
		
		

		return queryReturnsSingleInt(queryStr, "selectionCount");
	}
	
	public static int getBiojSelectionWithoutRDFtype() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT (COUNT(DISTINCT ?sel) as ?selectionCount)");
		queryStr.append("WHERE {");
		queryStr.append("  ?article bioj:has_selection ?sel  ");
		queryStr.append("  FILTER NOT EXISTS {");
		queryStr.append("    ?sel rdf:type bioj:selection .");
		queryStr.append("  } ");
		queryStr.append("}");
		
		return queryReturnsSingleInt(queryStr, "selectionCount");
	}
	
	public static int getArticlesPerStrata(String strataString) {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT (COUNT(DISTINCT ?article) as ?articleCount)");
		queryStr.append("WHERE {");
		queryStr.append("  ?article dc:isPartOf ?journal . ");
		queryStr.append("  ?journal bioj:strata \"");
		queryStr.append(strataString);
		queryStr.append("\" . ");
		queryStr.append("}");
		
		return queryReturnsSingleInt(queryStr, "articleCount");
	}
	
	private static int queryReturnsSingleInt (ParameterizedSparqlString paramQueryString, 
											  String targetVar) {
		Query query = paramQueryString.asQuery();
		
		// Execute the query and obtain results
		QueryExecution qe = QueryExecutionFactory.create(query, model);
		Iterator<QuerySolution> results = qe.execSelect();
		int count = -1;
		for ( ; results.hasNext() ; ) {
			QuerySolution soln = results.next() ;
			count = soln.get(targetVar).asLiteral().getInt();
		}
		return count;
	}
	
	public static int getArticleWithoutStrata() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT *");
		queryStr.append("WHERE {");
		queryStr.append("  ?article dc:isPartOf ?journal . ");
		queryStr.append("  FILTER NOT EXISTS {");
		queryStr.append("    ?journal bioj:strata ?strata");
		queryStr.append("  } ");
		queryStr.append("}");
		
		formatResultSet(queryStr);
		return -1;
	}
	
	private static void formatResultSet (ParameterizedSparqlString paramQueryString) {
		Query query = paramQueryString.asQuery();
		
		// Execute the query and obtain results
		QueryExecution qe = QueryExecutionFactory.create(query, model);
		ResultSet results = qe.execSelect();
		
		// Output query results	
		ResultSetFormatter.out(System.out, results, query);
		
		// Important - free up resources used running the query
		qe.close();

	}
		
}