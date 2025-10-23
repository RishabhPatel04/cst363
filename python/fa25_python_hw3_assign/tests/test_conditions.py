import pytest
from heap_db.schema import Schema
from heap_db.db_tuple import DbTuple
from heap_db.query_conditions import EqualsCondition, Condition

def make_row():
    s = Schema()
    s.add_key_int_type("id")
    s.add_varchar_type("name", 20)
    return DbTuple(s, 1, "Ada")

def test_equals_condition_match():
    row = make_row()
    cond = EqualsCondition("name", "Ada")
    assert cond.evaluate(row) is True  # TODO should make this pass

def test_equals_condition_no_match():
    row = make_row()
    cond = EqualsCondition("name", "Grace")
    assert cond.evaluate(row) is False

def test_equals_condition_missing_column_raises():
    row = make_row()
    cond = EqualsCondition("nope", "x")
    with pytest.raises(Exception):
        cond.evaluate(row)  # should raise via row.get_by_name/get

# OrCondition short-circuit + truth table
class TrueCond(Condition):
    def __init__(self): self.calls = 0
    def evaluate(self, row): self.calls += 1; return True

class FalseCond(Condition):
    def __init__(self): self.calls = 0
    def evaluate(self, row): self.calls += 1; return False

def test_or_condition_truth_table():
    row = object()
    assert (TrueCond() | TrueCond()).evaluate(row) is True
    assert (TrueCond() | FalseCond()).evaluate(row) is True
    assert (FalseCond() | TrueCond()).evaluate(row) is True
    assert (FalseCond() | FalseCond()).evaluate(row) is False  # fails until TODO done

def test_or_condition_short_circuit_left_true():
    row = object()
    left, right = TrueCond(), FalseCond()
    (left | right).evaluate(row)
    assert left.calls == 1 and right.calls == 0  # right must not be evaluated