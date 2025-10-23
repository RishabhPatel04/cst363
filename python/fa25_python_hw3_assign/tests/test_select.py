from heap_db.schema import Schema
from heap_db.table import Table
from heap_db.db_tuple import DbTuple
from heap_db.select_query import SelectQuery
from heap_db.query_conditions import Condition

class AlwaysTrue(Condition):
    def evaluate(self, row): return True

def make_people_table():
    s = Schema()
    s.add_key_int_type("id")
    s.add_varchar_type("name", 20)
    s.add_int_type("age")
    t = Table(s)
    t.insert(DbTuple(s, 1, "Ada", 37))
    t.insert(DbTuple(s, 2, "Grace", 28))
    return t

def test_select_all_keeps_schema_and_rows():
    tbl = make_people_table()
    out = SelectQuery(None, AlwaysTrue()).select(tbl)
    assert out.get_schema() is tbl.get_schema()
    assert len(list(out)) == len(list(tbl))

def test_projection_schema_and_values():
    tbl = make_people_table()
    out = SelectQuery(["name"], AlwaysTrue()).select(tbl)
    assert out.get_schema() is not tbl.get_schema()
    assert out.get_schema().size() == 1
    assert out.get_schema().get_name(0) == "name"
    names = [r.get_by_name("name") for r in out]
    assert set(names) == {"Ada", "Grace"}
