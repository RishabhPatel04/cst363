import pytest
from heap_db.schema import Schema
from heap_db.table import Table
from heap_db.db_tuple import DbTuple


@pytest.fixture
def table_instance():
    # Create schema with a primary key on "ID"
    schema = Schema()
    schema.add_key_int_type("ID")
    schema.add_varchar_type("name", 30)
    schema.add_varchar_type("dept_name", 30)
    schema.add_int_type("salary")
    
    # Create an initial list of tuples (rows)
    tuples = [
        DbTuple(schema, 22222, "Einstein",    "Physics",    95000),
        DbTuple(schema, 12121, "Wu",          "Finance",    90000),
        DbTuple(schema, 32343, "El Said",     "History",    60000),
        DbTuple(schema, 45565, "Katz",        "Comp. Sci.", 75000),
        DbTuple(schema, 98345, "Kim",         "Elec. Eng.", 80000),
        DbTuple(schema, 10101, "Srinivasan",  "Comp. Sci.", 65000),
        DbTuple(schema, 76766, "Crick",       "Biology",    72000),
    ]
    
    # Create table and insert the tuples
    table = Table(schema)
    for tup in tuples:
        table.insert(tup)
    
    # Prepare two extra tuples for testing insertions
    old_tup = DbTuple(schema, 22222, "Einstein", "Physics", 95000)
    new_tup = DbTuple(schema, 11111, "Molina",   "Music",   70000)
    
    return table, old_tup, new_tup

def test_insert_one_tuple(table_instance):
    """Test inserting a new tuple with a unique key."""
    table, _, new_tup = table_instance
    # Insertion should succeed for a unique key.
    assert table.insert(new_tup), "Insertion should succeed for a unique key."
    # lookup_by_key should return the inserted tuple.
    t = table.lookup_by_key(new_tup.get("ID"))
    assert t is not None, "Lookup should find the inserted tuple."

def test_insert_duplicate_tuple(table_instance):
    """Test inserting a duplicate tuple should fail."""
    table, old_tup, _ = table_instance
    # Inserting a tuple with an existing key should fail.
    assert not table.insert(old_tup), "Insertion should fail for duplicate key."

def test_lookup_existing_tuple(table_instance):
    """Test looking up an existing tuple by primary key."""
    table, old_tup, _ = table_instance
    # lookup_by_key returns a Tuple (not a table) for an existing key.
    ID = old_tup.get_int(0)
    result_tuple = table.lookup_by_key(ID)
    assert result_tuple is not None, "Lookup should return a tuple for an existing key."
    assert result_tuple.get_int(0) == ID, "Incorrect tuple returned."

def test_lookup_missing_tuple(table_instance):
    """Test looking up a missing tuple by primary key should return None."""
    table, _, _ = table_instance
    # lookup_by_key should return None if the key is missing.
    result = table.lookup_by_key(11111)
    assert result is None, "Lookup for missing ID should return None."

def test_lookup_non_key_column(table_instance):
    """Test looking up by a non-primary key column returns a Table."""
    table, _, _ = table_instance
    # lookup_by_column returns a Table of matching tuples.
    result = table.lookup_by_column("dept_name", "Comp. Sci.")
    assert result.size() == 2, "Table lookup should return 2 tuples for 'Comp. Sci.' department."

def test_schema_without_key():
    """Test table behavior when the schema has no primary key."""
    schema = Schema()
    schema.add_int_type("cola")
    schema.add_int_type("colb")
    table = Table(schema)
    
    table.insert(DbTuple(schema, 5, 10))
    table.insert(DbTuple(schema, 5, 11))
    
    assert table.size() == 2, "Table should contain two tuples."
    
    # For non-key lookups, lookup_by_column returns a Table.
    result = table.lookup_by_column("cola", 5)
    assert result.size() == 2, "Lookup should return both tuples."