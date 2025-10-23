from heap_db.schema import Schema
from heap_db.table import Table
from heap_db.db_tuple import DbTuple
from heap_db.select_query import SelectQuery

def test_natural_join_on_shared_column_counts():
    # inst(id,name,dept_name,salary)
    s1 = Schema()
    s1.add_key_int_type("ID")
    s1.add_varchar_type("name", 30)
    s1.add_varchar_type("dept_name", 15)
    s1.add_int_type("salary")
    t1 = Table(s1)
    t1.insert(DbTuple(s1, 1, "A", "CS", 100))
    t1.insert(DbTuple(s1, 2, "B", "EE", 200))

    # dept(dept_name,building,budget)
    s2 = Schema()
    s2.add_key_varchar_type("dept_name", 15)
    s2.add_varchar_type("building", 12)
    s2.add_int_type("budget")
    t2 = Table(s2)
    t2.insert(DbTuple(s2, "CS", "Gates", 1_000))
    t2.insert(DbTuple(s2, "EE", "Packard", 2_000))

    out = SelectQuery.natural_join(t1, t2)
    assert len(list(out)) == len(list(t1))  # fails until both join TODOs are done

def test_natural_join_no_common_columns_cartesian():
    s1 = Schema(); s1.add_key_int_type("a"); t1 = Table(s1); t1.insert(DbTuple(s1, 1))
    s2 = Schema(); s2.add_key_int_type("b"); t2 = Table(s2); t2.insert(DbTuple(s2, 10)); t2.insert(DbTuple(s2, 20))
    out = SelectQuery.natural_join(t1, t2)
    assert len(list(out)) == 2  # 1x2 cartesian
