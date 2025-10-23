from typing import List, Iterator, Optional
from .schema import Schema
from .db_tuple import DbTuple 

class Table:
    """Represents a table in a relational database."""

    def __init__(self, schema: Schema):
        """
        Initialize an empty table with a given schema.
        """
        self.schema = schema
        self.db_tuples: List[DbTuple] = []  # List to store db tuples

    def get_schema(self) -> Schema:
        """
        Return the schema of the table.
        """
        return self.schema  # Already implemented

    def size(self) -> int:
        """
        Return the number of db tuples (rows) in the table.
        """
        return len(self.db_tuples)  # Already implemented

    def close(self) -> None:
        """
        Close the table (for file-backed implementations).
        Currently does nothing.
        """
        pass  # Already implemented (no-op)

    def insert(self, rec: DbTuple) -> bool:
        """
        Insert a db tuple into the table.
        - If schema has no key, just add the db tuple.
        - If schema has a key, check for duplicates before inserting.

        :param rec: DbTuple to insert
        :return: True if insert succeeds, False if key already exists
        """
        if rec.get_schema() is not self.schema:
            raise ValueError("Error: db tuple schema object does not match table schema (must reuse the same Schema instance).")

        # - If the table has no primary key, append the db tuple to self.db_tuples.
        # - If the table has a primary key, check for duplicates.
        # - If a duplicate key is found, return False.
        # - Otherwise, append the db tuple and return True.

        key = self.schema.get_key()
        
        # no primary key, just insert and return True
        if key is None:
            self.db_tuples.append(rec)
            return True

        # get index of key
        key_index = self.schema.get_column_index(key)

        # check for duplicate, if found return False
        for t in self.db_tuples:
            if t.get(key_index) == rec.get(key_index):
                return False
        
        # insert and return True (no duplicates allowed)
        self.db_tuples.append(rec)
        return True




    def delete(self, key: object) -> bool:
        """
        Delete a db tuple given the primary key value.
        - If the table has no primary key, raise an error.
        - If key is found, remove the db tuple.

        :param key: The primary key value
        :return: True if deletion succeeds, False if key not found
        """
        if self.schema.key is None:
            raise ValueError("Error: table does not have a primary key. Cannot delete.")

        # - Iterate over self.db_tuples.
        # - If a db_tuple with the matching key is found, remove it from self.db_tuples and return True.
        # - If no match is found, return False.

        if self.schema.key is None:
            raise ValueError("Error: table does not have a primary key. Cannot delete.")
        
        key_column = self.schema.get_key()

        for t in self.db_tuples:
            if t.get(key_column) == key:
                self.db_tuples.remove(t)
                return True

        return False



    def lookup_by_key(self, key: object) -> Optional[DbTuple]:
        """
        σ Selection (special case on primary key):
        Return the db tuple in the table with the given primary key value.
        - If the table has no primary key, raise an error.
        - Return None if no such db tuple exists.

        :param key: The primary key value
        :return: DbTuple object if found, otherwise None
        """
        if self.schema.key is None:
            raise ValueError("Error: table does not have a primary key. Cannot lookup.")

        # - Iterate over self.db_tuples.
        # - If a db tuple with the matching primary key is found, return it.
        # - If no match is found, return None.


        if self.schema.key is None:
            raise ValueError("Error: table does not have a primary key. Cannot lookup.")

        key_column = self.schema.key

        for t in self.db_tuples:
            if t.get(key_column) == key:
                return t

        return None



    def lookup_by_column(self, colname: str, value: object) -> "Table":
        """
        σ Selection (general case):
        Return a subset of db tuples from this table that satisfy colname=value.

        :param colname: Name of the column to filter by
        :param value: Value to match
        :return: A new Table containing matching db tuples
        """
        if self.schema.get_column_index(colname) < 0:
            raise ValueError(f"Error: table does not contain column '{colname}'.")

        result_table = Table(self.schema)

        # - Iterate over self.db_tuples.
        # - If a db tuple has colname == value, insert it into result_table.
        # - Return result_table.

        if self.schema.get_column_index(colname) < 0:
            raise ValueError(f"Error: table does not contain column '{colname}'.")

        result_table = Table(self.schema)
    
        for t in self.db_tuples:
            if t.get_by_name(colname) == value:
                result_table.insert(t)

        return result_table



    def __iter__(self) -> Iterator[DbTuple]:
        """
        Return an iterator over the table's db tuples.
        """
        return iter(self.db_tuples)  # Already implemented

    def __str__(self) -> str:
        """
        Return a string representation of the table.
        """
        if not self.db_tuples:
            return "Empty Table"
        return "\n".join(str(t) for t in self.db_tuples)