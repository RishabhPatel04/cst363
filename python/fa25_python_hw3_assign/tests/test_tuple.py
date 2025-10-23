import pytest
from heap_db.db_tuple import DbTuple
from heap_db.schema import Schema

def test_create_test_record():
    """Create a tuple with three integer fields and verify values."""
    schema = Schema()
    schema.add_key_int_type('a')
    schema.add_int_type('b')
    schema.add_int_type('c')

    rec = DbTuple(schema, 1, 1, 1)

    assert rec.get_int(0) == 1
    assert rec.get_int(1) == 1
    assert rec.get_int(2) == 1


def test_varchar_type():
    """Test VARCHAR type constraints."""
    schema = Schema()
    schema.add_key_varchar_type('a', 4)
    schema.add_varchar_type('b', 2)

    # Verify that the schema's tuple size is computed as expected.
    assert schema.get_db_tuple_size_in_bytes() == 14

    # Expect a ValueError when inserting an oversized VARCHAR.
    with pytest.raises(ValueError, match="String too long"):
        DbTuple(schema, '1234', '123')  # '123' exceeds VARCHAR(2)

    # Create a valid tuple and verify retrieval.
    t = DbTuple(schema, '1234', '12')
    assert t.get(0) == '1234'
    assert t.get('a') == '1234'
    assert t.get_string(1) == '12'


def test_create_simple_record():
    """Construct a simple tuple and verify the field value."""
    schema = Schema()
    schema.add_int_type('a')
    rec = DbTuple(schema, 1)
    assert rec.get(0) == 1


def test_records_match_schema():
    """Ensure that the tuple constructor enforces schema constraints."""
    schema = Schema()
    schema.add_int_type('a')

    # Expect an error when providing too many values.
    with pytest.raises(ValueError, match="Number of values does not match schema size"):
        DbTuple(schema, 1, 2)
