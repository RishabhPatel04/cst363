from __future__ import annotations
from abc import ABC, abstractmethod
from dataclasses import dataclass
from .db_tuple import DbTuple


class Condition(ABC):
    """
    Abstract base class for all conditions used in filtering queries.
    """

    def __and__(self, other: "Condition") -> "Condition":
        return AndCondition(self, other)

    def __or__(self, other: "Condition") -> "Condition":
        return OrCondition(self, other)

    def __invert__(self) -> "Condition":
        return NotCondition(self)

    @abstractmethod
    def evaluate(self, row: DbTuple) -> bool:
        ...


@dataclass(frozen=True)
class EqualsCondition(Condition):
    """
    Represents an equality condition (e.g., column == value).
    """
    column_name: str
    value: object

    def evaluate(self, row: DbTuple) -> bool:
        """
        Compare the row's value for the given column to self.value.
        Uses row.get to allow name-based lookup and to surface errors for missing columns.
        """
        return row.get(self.column_name) == self.value

        
@dataclass(frozen=True)
class AndCondition(Condition):
    """
    Represents a logical AND of two conditions.
    """
    left: Condition
    right: Condition

    def evaluate(self, row: DbTuple) -> bool:
        """
        Evaluate the AND condition on the row.
        :return: True if both left and right conditions evaluate to True.
        """
        return self.left.evaluate(row) and self.right.evaluate(row)

@dataclass(frozen=True)
class OrCondition(Condition):
    """
    Represents a logical OR of two conditions.
    """

    left: Condition
    right: Condition

    def evaluate(self, row: DbTuple) -> bool:
        """
        Evaluate the OR condition on the row with short-circuiting.
        :return: True if at least one of the left or right conditions evaluates to True.
        """
        if self.left.evaluate(row):
            return True
        return self.right.evaluate(row)



@dataclass(frozen=True)
class NotCondition(Condition):
    inner: Condition

    def evaluate(self, row: DbTuple) -> bool:
        return not self.inner.evaluate(row)