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

import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;

import com.hp.hpl.jena.sparql.*;
import com.hp.hpl.jena.sparql.engine.*;

import org.topbraid.spin.constraints.ConstraintViolation;
import org.topbraid.spin.constraints.SPINConstraints;
import org.topbraid.spin.inference.SPINInferences;
import org.topbraid.spin.system.SPINLabels;
import org.topbraid.spin.system.SPINModuleRegistry;
import org.topbraid.spin.util.JenaUtil;



public class TTLRepository {
	
	public static InfModel model;
	
	public static String path = "/Users/howison/Documents/UTexas/Projects/SoftwareCitations/softcite/data/";
	
	public TTLRepository() {
		//
		
//		Class myClass = this.getClass();
//		URL fileURL =  myClass.getResource("testdata/SoftwareCitationDataset.ttl");
//		URL fileURL =  myClass.getClassLoader().getResource("testToLoad.txt");
//		String myPath = fileURL.getPath();  // this is throwing an NPE.
//		Model model = FileManager.get().loadModel(myPath);
		
		Model codedData =  FileManager.get().loadModel(
			path + "SoftwareCitationDataset.ttl" 
		);
		
		if (codedData == null) {
			throw new IllegalArgumentException(
			"ttl file not found");
		}
		
		this.model = ModelFactory.createRDFSModel(codedData);
		
		this.model.read(path + "VocabularyStatements.ttl");
		
		// Model infStatements = FileManager.get().loadModel(
		// 	path + "VocabularyStatements.ttl"
		// );
		//
		// if (infStatements == null) {
		// 	throw new IllegalArgumentException(
		// 	"inf ttl file not found");
		// }
		//
		// this.model.add(infStatements)
		//
		// // Add a basic rdfs reasoner.
		// InfModel inf = ModelFactory.createRDFSModel(this.model)
			
			
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
		
		queryStr.append("SELECT (COUNT(DISTINCT ?article) as ?articleCount)");
		queryStr.append("WHERE {");
		queryStr.append("  ?article dc:isPartOf ?journal . ");
		queryStr.append("  FILTER NOT EXISTS {");
		queryStr.append("    ?journal bioj:strata ?strata");
		queryStr.append("  } ");
		queryStr.append("}");
		
		
		return queryReturnsSingleInt(queryStr, "articleCount");
	}
	
	public static int getCodedObjectCount() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT (COUNT(?s) as ?codedObjectCount)");
		queryStr.append("WHERE {");
		queryStr.append("  ?s ca:isTargetOf [ ca:appliesCode ?code ] ");
		queryStr.append("}");
		
		return queryReturnsSingleInt(queryStr, "codedObjectCount");
	}
	
	public static int getCodeTypeCount() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append(" SELECT (COUNT(DISTINCT ?codeType) as ?codeTypeCount) ");
		queryStr.append(" WHERE { ");
		queryStr.append(" 	?s ca:appliesCode [ rdf:type ?codeType ] ");
		queryStr.append(" } ");
		// queryStr.append(" 	{  ");
		// queryStr.append(" 		?s ca:appliesCode ?codeType . ");
		// queryStr.append(" 		FILTER NOT EXISTS { ");
		// queryStr.append(" 		  ?codeType rdfs:label ?label ");
		// queryStr.append(" 		} ");
		// queryStr.append(" 	}  ");
		// queryStr.append(" 	UNION  ");
		// queryStr.append(" 	{ ");
		// queryStr.append(" 		?s ca:appliesCode ?code . ");
		// queryStr.append(" 		?code rdf:type ?codeType ");
		// queryStr.append(" 		FILTER EXISTS { ");
		// queryStr.append(" 		  ?code rdfs:label ?label ");
		// queryStr.append(" 		} ");
		// queryStr.append(" 	}  ");
		// queryStr.append(" } ");
		
		return queryReturnsSingleInt(queryStr, "codeTypeCount");
	}
	
	public static int getArticlesWithCodeApplied(String codeApplied) {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append(" SELECT (COUNT(DISTINCT ?article) as ?articleCount)  ");
		queryStr.append( getArticlesWithCodeAppliedQueryWherePart() );

		queryStr.setIri("code", codeApplied);
		return queryReturnsSingleInt(queryStr, "articleCount");
	}
	
	private static String getArticlesWithCodeAppliedQueryWherePart() {
		StringBuffer queryStr = new StringBuffer();
		
		queryStr.append(" WHERE");
		queryStr.append(" { ");
		queryStr.append(" 	?article bioj:has_selection ?sel . ");
		queryStr.append(" 	?article dc:isPartOf ?journal .");
		queryStr.append(" 	?journal bioj:strata ?strata . ");
		queryStr.append(" 	?sel ca:isTargetOf [ ca:appliesCode [ rdf:type ?code ] ] . ");
		queryStr.append(" 	OPTIONAL { ");
		queryStr.append("   		?sel bioj:has_reference ?ref . ");
		queryStr.append("   		?ref ca:isTargetOf [ ca:appliesCode [ rdf:type ?code ] ] . ");
		queryStr.append(" 	} ");
		queryStr.append(" }		 ");

		return queryStr.toString();
	}
	
	public static ResultSet getArticlesWithCodeAppliedByStrata(String codeApplied) {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append(" SELECT ?journal ?strata ?article ");
		queryStr.append( getArticlesWithCodeAppliedQueryWherePart() );
//		queryStr.append(" GROUP BY ?strata " );

		queryStr.setIri("code", codeApplied);
		
		Query query = queryStr.asQuery();
		
		// Execute the query and obtain results
		QueryExecution qe = QueryExecutionFactory.create(query, model);
		ResultSet results = qe.execSelect();
		
		return results;
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

	public static void getSoftwarePackageList() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT DISTINCT ?listOfUniqueSoftwareNames");
		queryStr.append("WHERE {");
		queryStr.append("  ?selection red:type citec:software_name . ");
		queryStr.append("  ?selection rdfs:label ?listOfUniqueSoftwareNames .");
		queryStr.append("}");
		
		formatResultSet(queryStr);
	}
	
	public static ResultSet getCodedResults() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);

		queryStr.append("SELECT ?selection ?article ?journal ?strata ?code");
		queryStr.append(" WHERE");
		queryStr.append(" { ");
		queryStr.append(" 	?article bioj:has_selection ?selection . ");
		queryStr.append(" 	?article dc:isPartOf ?journal .");
		queryStr.append(" 	?journal bioj:strata ?strata . ");
		queryStr.append(" 	?selection ca:isTargetOf [ ca:appliesCode [ rdf:type ?code ] ] . ");
		queryStr.append(" 	OPTIONAL { ");
		queryStr.append("   		?selection bioj:has_reference ?ref . ");
		queryStr.append("   		?ref ca:isTargetOf [ ca:appliesCode [ rdf:type ?code ] ] . ");
		queryStr.append(" 	} ");
		queryStr.append(" }		 ");

		Query query = queryStr.asQuery();
		
		// Execute the query and obtain results
		QueryExecution qe = QueryExecutionFactory.create(query, model);
		ResultSet results = qe.execSelect();
		
		return results;
	}
	
	public static int countReferenceSelections() {
		ParameterizedSparqlString queryStr = new ParameterizedSparqlString(model);
		
		queryStr.append("SELECT (COUNT(DISTINCT ?ref) as ?refCount)");
		queryStr.append("WHERE {");
		queryStr.append("  ?ref rdf:type bioj:ReferenceSelection . ");
		queryStr.append("}");
		
		
		return queryReturnsSingleInt(queryStr, "refCount");
	}
	
	
	
	public static void runSPINrules() {
	//	model.read(
//	"https://raw.github.com/jameshowison/softcite/spin-attempt/data/SPINrules.ttl");
		
		model.read(path + "SPINrules.ttl");
		
		// Create OntModel with imports
		OntModel ontModel = JenaUtil.createOntologyModel(OntModelSpec.OWL_MEM,model);
		
		// Create and add Model for inferred triples
		// reuse prefixes.
		Model newTriples = ModelFactory.createDefaultModel();
		newTriples.setNsPrefixes(model);
		ontModel.addSubModel(newTriples);

		// Register locally defined functions
		SPINModuleRegistry.get().registerAll(ontModel, null);

		// Run all inferences
		SPINInferences.run(ontModel, newTriples, null, null, false, null);
		System.out.println("Inferred triples: " + newTriples.size());
		
		newTriples.write(System.out, "TTL");
	}
	
		
}