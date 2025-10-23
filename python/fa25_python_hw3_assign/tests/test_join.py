import pytest
from heap_db.schema import Schema
from heap_db.table import Table
from heap_db.db_tuple import DbTuple
from heap_db.select_query import SelectQuery


@pytest.fixture
def setup_tables():
    # Setup for the "inst" (instructor) table
    inst_schema = Schema()
    inst_schema.add_key_int_type("ID")
    inst_schema.add_varchar_type("name", 30)
    inst_schema.add_varchar_type("dept_name", 15)
    inst_schema.add_int_type("salary")
    inst_tuples = [
        DbTuple(inst_schema, 22222, "Einstein",    "Physics",   95000),
        DbTuple(inst_schema, 12121, "Wu",          "Finance",   90000),
        DbTuple(inst_schema, 32343, "El Said",     "History",   60000),
        DbTuple(inst_schema, 45565, "Katz",        "Comp. Sci.",75000),
        DbTuple(inst_schema, 98345, "Kim",         "Elec. Eng.",80000),
        DbTuple(inst_schema, 10101, "Srinivasan",  "Comp. Sci.",65000),
        DbTuple(inst_schema, 76766, "Crick",       "Biology",   72000),
    ]
    inst_table = Table(inst_schema)
    for tup in inst_tuples:
        inst_table.insert(tup)
    
    # Setup for the department table
    dept_schema = Schema()
    dept_schema.add_key_varchar_type("dept_name", 15)
    dept_schema.add_varchar_type("building", 12)
    dept_schema.add_int_type("budget")
    dept_tuples = [
        DbTuple(dept_schema, "Biology",    "Watson",  90000),
        DbTuple(dept_schema, "Comp. Sci.", "Taylor",  100000),
        DbTuple(dept_schema, "Elec. Eng.", "Taylor",  85000),
        DbTuple(dept_schema, "Finance",    "Painter", 120000),
        DbTuple(dept_schema, "Music",      "Packard", 80000),
        DbTuple(dept_schema, "History",    "Painter", 50000),
        DbTuple(dept_schema, "Physics",    "Watson",  70000),
    ]
    dept_table = Table(dept_schema)
    for tup in dept_tuples:
        dept_table.insert(tup)
    
    return {
        "inst_schema": inst_schema,
        "inst_table": inst_table,
        "dept_schema": dept_schema,
        "dept_table": dept_table,
    }

def test_single_int_primary_key(setup_tables):
    inst_table = setup_tables["inst_table"]
    inst_schema = setup_tables["inst_schema"]
    
    initial_size = inst_table.size()
    # Try to insert a tuple with the same ID as Einstein (22222)
    dup_tuple = DbTuple(inst_schema, 22222, "Royce", "Physics", 85000)
    result = inst_table.insert(dup_tuple)
    
    # Duplicate insertion should fail, table size should remain unchanged.
    assert result is False
    assert inst_table.size() == initial_size

def test_single_string_primary_key(setup_tables):
    dept_table = setup_tables["dept_table"]
    dept_schema = setup_tables["dept_schema"]
    
    initial_size = dept_table.size()
    # Try to insert a duplicate department (primary key "dept_name" == "Physics")
    dup_tuple = DbTuple(dept_schema, "Physics", "Champman", 120000)
    result = dept_table.insert(dup_tuple)
    
    # Duplicate insertion should fail, table size should remain unchanged.
    assert result is False
    assert dept_table.size() == initial_size

def test_schema_join(setup_tables):
    inst_schema = setup_tables["inst_schema"]
    dept_schema = setup_tables["dept_schema"]
    
    # Natural join of schemas: common column "dept_name" should merge, giving 6 total columns.
    joined_schema = inst_schema.natural_join(dept_schema)
    assert joined_schema is not None
    assert joined_schema.size() == 6

def test_table_join(setup_tables):
    inst_table = setup_tables["inst_table"]
    dept_table = setup_tables["dept_table"]
    
    # Assume SelectQuery.natural_join performs a natural join between two tables.
    joined_table = SelectQuery.natural_join(inst_table, dept_table)
    assert joined_table is not None
    # The test expects the joined table to have the same number of tuples as inst_table.
    assert joined_table.size() == inst_table.size()