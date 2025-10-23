from typing import List, Any, Optional, Union, Iterator, final
from struct import unpack_from
from .schema import Schema 
from .column_types import TypeInt, TypeVarchar


INT32_MIN = -(1 << 31)  # -2,147,483,648
INT32_MAX =  (1 << 31) - 1  # 2,147,483,647

@final
class DbTuple:
    """Represents a row of data in a table, associated with a schema."""

    def __init__(self, schema: Schema, *values: Any):
        """
        Create a db tuple given a schema and column values.
        - If values are provided, they must match the schema size.
        - If no values are provided, initialize defaults:
          * VARCHAR -> "", others -> None (PK may raise if default None).
        """

        size = schema.size()
        if values and len(values) != size:
            raise ValueError("Number of values does not match schema size.")

        self.schema = schema
        self.values: List[Any] = [None] * size

        if values:
            for i, v in enumerate(values):
                self.set(i, v)
        else:
            for i in range(size):
                t = schema.get_type(i)
                default = "" if isinstance(t, TypeVarchar) else None
                self.set(i, default)


    @classmethod
    def join_db_tuple(cls, schema: Schema, t1: "DbTuple", t2: "DbTuple") -> "DbTuple":
        """
        Create a new db tuple by joining two db tuples based on the provided schema.
        - The first `t1.size()` fields come from `t1`.
        - The remaining fields come from `t2`, mapped to `schema`.
        """

        t1_size = t1.schema.size()
        for i in range(t1_size):
            if schema.get_name(i) != t1.schema.get_name(i):
                raise ValueError("Join schema's first columns must match t1's schema order")

        new_values: List[Any] = []

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
                raise ValueError(f"Column '{i}' not found.")
            i = col_index  

        if i < 0 or i >= self.schema.size():
            raise ValueError(f"Invalid column index {i}.")

        return self.values[i]


    def get_int(self, i: int) -> int:
        """Return the integer value of the ith column."""
        value = self.get(i)

        if not isinstance(self.schema.get_type(i), TypeInt):
            raise ValueError(f"Column {i} is not an integer.")

        if value is None:
            raise ValueError(f"Column {i} is NULL (expected int).")
        return int(value)

    def get_string(self, i: int) -> str:
        """Return the string value of the ith column."""
        value = self.get(i)

        if not isinstance(self.schema.get_type(i), TypeVarchar):
            raise ValueError(f"Column {i} is not a string.")
        if value is None:
            raise ValueError(f"Column {i} is NULL (expected string).")

        return str(value)

    def get_by_name(self, name: str) -> Any:
        """Return the value of a column by its name."""
        index = self.schema.get_column_index(name)
        if index == -1:
            raise ValueError(f"Invalid column name '{name}'.")
        return self.get(index)
    
    def set(self, i: int, value: Any) -> None:
        """Set the value of the ith column."""
        if i < 0 or i >= self.schema.size():
            raise ValueError("Column index out of bounds.")

        col_type = self.schema.get_type(i)
        col_name = self.schema.get_name(i)

        # Disallow None for PRIMARY KEY
        key_name = self.schema.get_key()
        if key_name is not None and col_name == key_name and value is None:
            raise ValueError(f"Primary key '{key_name}' cannot be None")

        # Allow None for non-PK columns except VARCHAR
        if value is None:
            if isinstance(col_type, TypeVarchar):
                raise ValueError("String is null.")
            self.values[i] = None
            return

        # INT: type + 32-bit range checks
        if isinstance(col_type, TypeInt):
            if not isinstance(value, int) or isinstance(value, bool):
                raise TypeError(f"Column '{col_name}' expects int")
            if value < INT32_MIN or value > INT32_MAX:
                raise OverflowError("INT out of 32-bit signed range")

        # For VARCHAR, enforce max length in UTF-8 BYTES (not characters).
        if isinstance(col_type, TypeVarchar):
            s = str(value)                   # normalize to string (matches serialization)
            if len(s.encode("utf-8")) > self.schema.get_max_sql_size(i):
                raise ValueError("String too long.")
            value = s                        # store normalized string

        self.values[i] = value


    def get_key(self) -> Optional[Any]:
        """Return the value of the primary key column, if one exists."""
        key_column = self.schema.get_key()
        if key_column is None:
            return None
        return self.get_by_name(key_column)

    def projection(self, schema: Schema) -> "DbTuple":
        """
        Return a new db tuple containing only the subset of values specified by `schema`.
        """
        projected_values = [self.get_by_name(schema.get_name(i)) for i in range(schema.size())]
        return DbTuple(schema, *projected_values)

    def serialize(self) -> bytes:
        """Serialize the db tuple to a binary format."""
        buf = bytearray()
        for i in range(self.schema.size()):
            t = self.schema.get_type(i)
            v = self.values[i]
            if v is None:
                raise ValueError(f"Cannot serialize NULL at column {i} without null encoding")
            t.write_value(v, buf)
        return bytes(buf)



    @classmethod
    def deserialize(cls, schema: Schema, byte_data: bytes) -> "DbTuple":
        buf = memoryview(byte_data)
        offset = 0
        values: List[Any] = []
        for i in range(schema.size()):
            t = schema.get_type(i)
            val, offset = t.read_value(buf, offset)  # type parses itself and advances offset
            values.append(val)
        if offset != len(buf):
            raise ValueError(f"Extra {len(buf) - offset} bytes after tuple payload")
        return cls(schema, *values)


    def __repr__(self) -> str:
        """Return a string representation of the db_tuple."""
        return f"[{', '.join(map(repr, self.values))}]"

    def __len__(self) -> int: return len(self.values)

    def __iter__(self) -> Iterator[Any]: return iter(self.values)
    
    def __getitem__(self, i: Union[int, str]) -> Any: return self.get(i)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, DbTuple) and self.schema is other.schema and self.values == other.values

    def to_dict(self) -> dict[str, Any]:
        return {self.schema.get_name(i): self.values[i] for i in range(self.schema.size())}
