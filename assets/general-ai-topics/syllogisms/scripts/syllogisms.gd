extends Node2D


# Syllogism reasoning system for Godot 4
# Handles "is_a", "has_a", "is_at", and "comes_from" relationships

enum RelationType {
	IS_A,      # Inheritance/type relationship (e.g., "Socrates is a human")
	HAS_A,     # Possession/composition (e.g., "human has a brain")
	IS_AT,     # Location (e.g., "Socrates is at Athens")
	COMES_FROM # Origin (e.g., "Socrates comes from Athens")
}

class Fact:
	var subject: String
	var relation: RelationType
	var object: String
	
	func _init(s: String, r: RelationType, o: String):
		subject = s.to_lower().strip_edges()
		relation = r
		object = o.to_lower().strip_edges()
	
	func as_string() -> String:
		var rel_str = ""
		match relation:
			RelationType.IS_A: rel_str = "is a"
			RelationType.HAS_A: rel_str = "has a"
			RelationType.IS_AT: rel_str = "is at"
			RelationType.COMES_FROM: rel_str = "comes from"
		return "%s %s %s" % [subject, rel_str, object]

# Database storage
var facts: Array[Fact] = []

func _ready():
	print("=== Syllogism Reasoning System ===")
	print("Available commands:")
	print("  add_fact(subject, relation, object)")
	print("  query(subject, relation)")
	print("  query_all(subject)")
	print("  can_infer(subject, relation, object)")
	print("")
	
	# Example usage
	_run_example()

func add_fact(subject: String, relation: String, object: String) -> void:
	var rel_type = _parse_relation(relation)
	if rel_type == -1:
		print("Error: Invalid relation type. Use: is_a, has_a, is_at, comes_from")
		return
	
	var fact = Fact.new(subject, rel_type, object)
	facts.append(fact)
	print("Added: %s" % fact.as_string())

func _parse_relation(relation: String) -> int:
	match relation.to_lower().strip_edges():
		"is_a", "is a", "isa": return RelationType.IS_A
		"has_a", "has a", "hasa": return RelationType.HAS_A
		"is_at", "is at", "isat": return RelationType.IS_AT
		"comes_from", "comes from", "comesfrom": return RelationType.COMES_FROM
		_: return -1

func query(subject: String, relation: String) -> Array:
	var rel_type = _parse_relation(relation)
	if rel_type == -1:
		print("Error: Invalid relation type")
		return []
	
	var results = []
	var subj = subject.to_lower().strip_edges()
	
	# Direct facts
	for fact in facts:
		if fact.subject == subj and fact.relation == rel_type:
			results.append(fact.object)
	
	# Inferred facts (transitive reasoning)
	var inferred = _infer_facts(subj, rel_type)
	for item in inferred:
		if item not in results:
			results.append(item)
	
	return results

func query_all(subject: String) -> Dictionary:
	var subj = subject.to_lower().strip_edges()
	var results = {
		"is_a": [],
		"has_a": [],
		"is_at": [],
		"comes_from": []
	}
	
	for rel_type in [RelationType.IS_A, RelationType.HAS_A, RelationType.IS_AT, RelationType.COMES_FROM]:
		var rel_name = _relation_as_string(rel_type)
		results[rel_name] = query(subj, rel_name)
	
	return results

func can_infer(subject: String, relation: String, object: String) -> bool:
	var results = query(subject, relation)
	return object.to_lower().strip_edges() in results

func _infer_facts(subject: String, relation: RelationType) -> Array:
	var inferred = []
	
	match relation:
		RelationType.IS_A:
			# Transitive: if A is_a B and B is_a C, then A is_a C
			inferred = _transitive_closure(subject, RelationType.IS_A)
			# Inheritance: if A is_a B and B has_a C, then A has_a C
			var types = _transitive_closure(subject, RelationType.IS_A)
			for type in types:
				for fact in facts:
					if fact.subject == type and fact.relation == RelationType.HAS_A:
						if fact.object not in inferred:
							inferred.append(fact.object)
		
		RelationType.HAS_A:
			# If A is_a B and B has_a C, then A has_a C
			var types = _transitive_closure(subject, RelationType.IS_A)
			for type in types:
				for fact in facts:
					if fact.subject == type and fact.relation == RelationType.HAS_A:
						if fact.object not in inferred:
							inferred.append(fact.object)
		
		RelationType.IS_AT:
			# Simple containment: if A is_at B and B is_at C, then A is_at C
			inferred = _transitive_closure(subject, RelationType.IS_AT)
		
		RelationType.COMES_FROM:
			# Transitive origin tracking
			inferred = _transitive_closure(subject, RelationType.COMES_FROM)
	
	return inferred

func _transitive_closure(subject: String, relation: RelationType, visited: Array = []) -> Array:
	if subject in visited:
		return []
	
	visited.append(subject)
	var results = []
	
	for fact in facts:
		if fact.subject == subject and fact.relation == relation:
			if fact.object not in results:
				results.append(fact.object)
			
			# Recursively find transitive relationships
			var deeper = _transitive_closure(fact.object, relation, visited)
			for item in deeper:
				if item not in results:
					results.append(item)
	
	return results

func _relation_as_string(rel: RelationType) -> String:
	match rel:
		RelationType.IS_A: return "is_a"
		RelationType.HAS_A: return "has_a"
		RelationType.IS_AT: return "is_at"
		RelationType.COMES_FROM: return "comes_from"
		_: return "unknown"

func print_database() -> void:
	print("\n=== Database Contents ===")
	if facts.is_empty():
		print("(empty)")
		return
	
	for fact in facts:
		print("  %s" % fact.as_string())

func clear_database() -> void:
	facts.clear()
	print("Database cleared")

func _run_example():
	print("Running example...")
	print("")
	
	# Build knowledge base
	add_fact("Socrates", "is_a", "human")
	add_fact("human", "is_a", "mammal")
	add_fact("mammal", "is_a", "animal")
	add_fact("human", "has_a", "brain")
	add_fact("mammal", "has_a", "heart")
	add_fact("Socrates", "is_at", "Athens")
	add_fact("Athens", "is_at", "Greece")
	add_fact("Socrates", "comes_from", "Athens")
	print("")
	
	# Query examples
	print("=== Queries ===")
	print("What is Socrates?")
	var types = query("Socrates", "is_a")
	print("  Answer: %s" % str(types))
	print("")
	
	print("What does Socrates have?")
	var has = query("Socrates", "has_a")
	print("  Answer: %s" % str(has))
	print("")
	
	print("Where is Socrates?")
	var location = query("Socrates", "is_at")
	print("  Answer: %s" % str(location))
	print("")
	
	print("Can we infer 'Socrates is_a animal'?")
	print("  Answer: %s" % str(can_infer("Socrates", "is_a", "animal")))
	print("")
	
	print("Can we infer 'Socrates has_a heart'?")
	print("  Answer: %s" % str(can_infer("Socrates", "has_a", "heart")))
	print("")
	
	print("All facts about Socrates:")
	var all_facts = query_all("Socrates")
	for rel_type in all_facts:
		if not all_facts[rel_type].is_empty():
			print("  %s: %s" % [rel_type, str(all_facts[rel_type])])
	
	print("")
	print_database()
	
	
