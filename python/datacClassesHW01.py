from dataclasses import dataclass
from typing import List, Optional, Union

@dataclass(eq=False) 
class Instructor:
    ID: int
    name: str
    dept_name: str
    salary: int

    def __eq__(self, other):
        """
        Stub for equality comparison.
        Should compare only the ID attribute.
        """
        raise NotImplementedError("Equality method not implemented yet.")

class Table:
    """
    Simulates a database table containing rows of Instructor objects.
    Methods to complete:
        insert: Adds a new instructor to the table.
        delete: Removes an instructor by ID.
        lookup: Finds an instructor by ID.
        eval: Filters rows based on an attribute and value.
    """

    def __init__(self):
        self.instructors = []

    def insert(self, instructor: Instructor) -> bool:
        """
        TODO
        Add an Instructor object to the table.
        If an Instructor with the same ID exists, return False.
        Otherwise, add the Instructor and return True.
        """

    def delete(self, ID: int) -> bool:
        """
        TODO
        Remove the Instructor with the specified ID from the table.
        If no such Instructor exists, return False. Otherwise, return True.
        """

    def lookup(self, ID: int) -> Optional[Instructor]:
        """
        TODO
        Find and return the Instructor with the specified ID.
        Return None if no such Instructor exists.
        """

    def eval(self, attr_name: str, attr_value: Union[int, str]) -> List[Instructor]:
        """
        TODO
        Return a list of Instructors that match the specified attribute and value.
        attr_name can be 'ID', 'name', 'dept_name', or 'salary'.
        """

    def __str__(self) -> str:
        """
        Return a string representation of the table.
        """
        if not self.instructors:
            return "Empty Table"

        result = ""
        for i in self.instructors:
            result += str(i) + "\n"
        return result