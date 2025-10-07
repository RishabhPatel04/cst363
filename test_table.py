import pytest
from schema import Schema
from table import Table
from db_tuple import DbTuple


def setup_table():
    """Helper function to initialize a Table with sample tuples."""
    schema = Schema()
    schema.add_key_int_type("ID")   # primary key ID int
    schema.add_varchar_type("name", 30)
    schema.add_varchar_type("dept_name", 30)
    schema.add_int_type("salary")

    db_tuples = [
        DbTuple(schema, 22222, "Einstein", "Physics", 95000),
        DbTuple(schema, 12121, "Wu", "Finance", 90000),
        DbTuple(schema, 32343, "El Said", "History", 60000),
        DbTuple(schema, 45565, "Katz", "Comp. Sci.", 75000),
        DbTuple(schema, 98345, "Kim", "Elec. Eng.", 80000),
        DbTuple(schema, 10101, "Srinivasan", "Comp. Sci.", 65000),
        DbTuple(schema, 76766, "Crick", "Biology", 72000),
    ]

    table = Table(schema)
    for tup in db_tuples:
        table.insert(tup)

    old_tup = DbTuple(schema, 22222, "Einstein", "Physics", 95000)
    new_tup = DbTuple(schema, 11111, "Molina", "Music", 70000)

    return table, old_tup, new_tup


def test_insert_one_db_tuple():
    """Test inserting a new db tuple with a unique key."""
    table, _, new_db_tup = setup_table()
    
    insert_succeeded = table.insert(new_db_tup)
    assert insert_succeeded, "Insertion should succeed for a unique key."
    
    t = table.lookup_by_key(new_db_tup.get("ID"))  
    assert t is not None, "Lookup should find the inserted db tuple."


def test_insert_duplicate_db_tuple():
    """Test inserting a duplicate db tuple should fail."""
    table, old_db_tup, _ = setup_table()

    insert_succeeded = table.insert(old_db_tup)
    assert not insert_succeeded, "Insertion should fail for duplicate key."


def test_lookup_existing_db_tuple():
    """Test looking up an existing db tuple by primary key."""
    table, old_db_tup, _ = setup_table()
    
    ID = old_db_tup.get_int(0)
    result = table.lookup_by_key(ID)  
    
    assert result is not None, "Lookup should return a db tuple."
    assert result.get_int(0) == ID, "Incorrect db tuple returned."


def test_lookup_missing_db_tuple():
    """Test looking up a missing db tuple should return None."""
    table, _, _ = setup_table()
    
    result = table.lookup_by_key(11111)  
    assert result is None, "Lookup for missing ID should return None."


def test_lookup_non_key_column():
    """Test looking up by a non-primary key column."""
    table, _, _ = setup_table()
    
    result = table.lookup_by_column("dept_name", "Comp. Sci.") 
    assert result.size() == 2, "Table lookup should return 2 tuples for 'Comp. Sci.' department."


def test_schema_without_key():
    """Test table behavior when schema has no primary key."""
    schema = Schema()
    schema.add_int_type("cola")
    schema.add_int_type("colb")

    table = Table(schema)
    
    table.insert(DbTuple(schema, 5, 10))
    table.insert(DbTuple(schema, 5, 11))
    
    assert table.size() == 2, "Table should contain two tuples."
    
    result = table.lookup_by_column("cola", 5) 
    assert result.size() == 2, "Lookup should return both tuples."