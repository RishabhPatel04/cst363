from typing import List, Any, Optional, Union
from schema import Schema  # Import Schema class
from column_types import TypeInt, TypeVarchar


class DbTuple:
    """Represents a row of data in a table, associated with a schema."""

    def __init__(self, schema: Schema, *values: Any):
        """
        Create a db tuple given a schema and column values.
        - If values are provided, they must match the schema size.
        - If no values are provided, initialize with None.
        """
        if values and len(values) != schema.size():
            raise ValueError("Error: Number of values does not match schema size.")

        self.schema = schema
        self.values = [None] * schema.size()
        key_name = schema.get_key()
        if values:
            for i, v in enumerate(values):
                if key_name is not None and schema.get_name(i) == key_name and v is None:
                    raise ValueError(f"Primary key '{key_name}' cannot be None")
                self.set(i, v)



    @classmethod
    def join_db_tuple(cls, schema: Schema, t1: "DbTuple", t2: "DbTuple") -> "DbTuple":
        """
        Create a new db tuple by joining two db tuples based on the provided schema.
        - The first `t1.size()` fields come from `t1`.
        - The remaining fields come from `t2`, mapped to `schema`.
        """
        new_values = []
        t1_size = t1.schema.size()
        for i in range(schema.size()):
            if i < t1_size:
                new_values.append(t1.values[i])
            else:
                new_values.append(t2.get(schema.get_name(i)))
        return cls(schema, *new_values)

    def get_schema(self) -> Schema:
        """Return the schema of this db tuple."""
        return self.schema

    def get(self, i: Union[int, str]) -> Any:
        """Return the value of the ith column, allowing both index and name lookup."""
        
        # Convert column name to index if `i` is a string
        if isinstance(i, str):
            col_index = self.schema.get_column_index(i)
            if col_index == -1:
                raise ValueError(f"Error: Column '{i}' not found.")
            i = col_index  

        if i < 0 or i >= self.schema.size():
            raise ValueError(f"Error: Invalid column index {i}.")

        return self.values[i]


    def get_int(self, i: int) -> int:
        """Return the integer value of the ith column."""
        value = self.get(i)
        if not isinstance(self.schema.get_type(i), TypeInt):
            raise ValueError(f"Error: Column {i} is not an integer.")
        return int(value)

    def get_string(self, i: int) -> str:
        """Return the string value of the ith column."""
        value = self.get(i)
        if not isinstance(self.schema.get_type(i), TypeVarchar):
            raise ValueError(f"Error: Column {i} is not a string.")
        return str(value)

    def get_by_name(self, name: str) -> Any:
        """Return the value of a column by its name."""
        index = self.schema.get_column_index(name)
        if index == -1:
            raise ValueError(f"Error: Invalid column name '{name}'.")
        return self.get(index)
    
    def set(self, i: int, value: Any) -> None:
        """Set the value of the ith column."""
        if i < 0 or i >= self.schema.size():
            raise ValueError("Error: Column index out of bounds.")

        col_type = self.schema.get_type(i)

        # Disallow None for PRIMARY KEY
        key_name = self.schema.get_key()
        if key_name is not None and self.schema.get_name(i) == key_name and value is None:
            raise ValueError(f"Primary key '{key_name}' cannot be None")

        # Allow None for non-PK columns except VARCHAR
        if value is None:
            if isinstance(col_type, TypeVarchar):
                raise ValueError("Error: String is null.")
            self.values[i] = None
            return

        # INT: type + 32-bit range checks
        if isinstance(col_type, TypeInt):
            if not isinstance(value, int):
                raise TypeError(f"Column '{self.schema.get_name(i)}' expects int")
            if value < -2147483648 or value > 2147483647:
                raise OverflowError("INT out of 32-bit signed range")

        # For VARCHAR, enforce max length in UTF-8 BYTES (not characters).
        if isinstance(col_type, TypeVarchar):
            s = str(value)                   # normalize to string (matches serialization)
            if len(s.encode("utf-8")) > self.schema.get_max_sql_size(i):
                raise ValueError("Error: String too long.")
            value = s                        # store normalized string

        self.values[i] = value


    def get_key(self) -> Optional[Any]:
        """Return the value of the primary key column, if one exists."""
        key_column = self.schema.get_key()
        if key_column is None:
            return None
        return self.get_by_name(key_column)

    def project(self, schema: Schema) -> "DbTuple":
        """
        Return a new db tuple containing only the subset of values specified by `schema`.
        """
        projected_values = [self.get_by_name(schema.get_name(i)) for i in range(schema.size())]
        return DbTuple(schema, *projected_values)

    def serialize(self) -> bytes:
        """Serialize the db tuple to a binary format."""
        buffer = bytearray()
        for i, column in enumerate(self.schema.columns):
            column.write_value(self.values[i], buffer)
        return bytes(buffer)

    def __repr__(self) -> str:
        """Return a string representation of the db tuple."""
        return f"[{', '.join(map(str, self.values))}]"