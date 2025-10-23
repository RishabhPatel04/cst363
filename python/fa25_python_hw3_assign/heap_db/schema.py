from typing import Optional, Any, List
from .column_types import TypeInt, TypeVarchar
from struct import pack, unpack_from

MAX_COLUMN_NAME_LENGTH = 24

"""
In a relational database, a schema defines:
- Column names
- Data types (e.g., INTEGER, VARCHAR(50))
- Primary keys (which uniquely identify records)
- Constraints (e.g., NOT NULL, UNIQUE)

Schema class defines the the structure of a table.
Schema here acts like a a metadata store for a table

schema = Schema()

schema.add_key_int_type("id")           # id -> INT PRIMARY KEY
schema.add_varchar_type("name", 50)     # name -> VARCHAR(50)
schema.add_int_type("age")              # age -> INT

is equivalent to

CREATE TABLE my_table (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT
);
"""


class Schema:
    """Represents the schema of a database table."""
    def __init__(self):
        self.columns: List[Any] = []  # List of column objects
        self.key: Optional[str] = None  # Primary key (None if no key)


    def _ensure_unique(self, name: str) -> None:
        if self.get_column_index(name) != -1:
            raise ValueError(f"Duplicate column name '{name}'.")

    def _ensure_no_key(self) -> None:
        if self.key is not None:
            raise ValueError(f"Primary key already set to '{self.key}'.")


    def add_varchar_type(self, column_name: str, max_size: int):
        """Add a VARCHAR column to the schema."""
        if not column_name:
            raise ValueError("Column name must be non-empty.")

        if len(column_name) > MAX_COLUMN_NAME_LENGTH:
            raise ValueError(f"Column name '{column_name}' exceeds {MAX_COLUMN_NAME_LENGTH} characters.")

        if max_size <= 0:
            raise ValueError("VARCHAR max_size must be > 0.")
        
        self._ensure_unique(column_name)
        self.columns.append(TypeVarchar(column_name, max_size))

    def add_int_type(self, column_name: str) -> None:
        """Add an INT column to the schema."""

        if not column_name:
            raise ValueError("Column name must be non-empty.")

        if len(column_name) > MAX_COLUMN_NAME_LENGTH:
            raise ValueError(f"Column name '{column_name}' exceeds {MAX_COLUMN_NAME_LENGTH} characters.")

        self._ensure_unique(column_name)
        self.columns.append(TypeInt(column_name))

    def add_key_int_type(self, column_name: str) -> None:
        """Add an INT column as the primary key."""

        self._ensure_no_key()
        self.add_int_type(column_name)
        self.key = column_name

    def add_key_varchar_type(self, column_name: str, max_size: int) -> None:
        """Add a VARCHAR column that is also the primary key."""
        self._ensure_no_key()
        self.add_varchar_type(column_name, max_size)
        self.key = column_name 

    def get_key(self) -> Optional[str]:
        """Return the primary key column name, or None if no key exists."""
        return self.key

    def get_column_index(self, column_name: str) -> int:
        """Return the index of the column with the given name, or -1 if not found."""
        for i, column in enumerate(self.columns):
            if column.get_column_name() == column_name:
                return i
        return -1

    def get_type(self, index: int) -> Any:
        """Return the column type at the given index."""
        return self.columns[index]

    def get_name(self, index: int) -> str:
        """Return the column name at the given index."""
        if not (0 <= index < len(self.columns)):
            raise ValueError(f"No column at index {index}")
        return self.columns[index].get_column_name()
    
    def get_max_sql_size(self, index: int) -> int:
        """Return the maximum SQL size of the column at the given index."""
        return self.columns[index].get_max_sql_length()

    def size(self) -> int:
        """Return the number of columns in the schema."""
        return len(self.columns)

    def get_db_tuple_size_in_bytes(self) -> int:
        """Return the total size of a db tuple in bytes."""
        return sum(column.get_max_size_bytes() for column in self.columns)

    def projection(self, attrs: List[str]) -> "Schema":
        """
        π Projection (Relational Algebra):
        Return a Schema that is a projection of the given list of column names.
        """
        projected_schema = Schema()
        for attr in attrs:
            index = self.get_column_index(attr)
            if index == -1:
                raise ValueError(f"Column '{attr}' not found in schema.")
            projected_schema.columns.append(self.get_type(index))
        if self.key in attrs:
            projected_schema.key = self.key
        return projected_schema

    def natural_join(self, other: "Schema") -> "Schema":
        """
        ⨝ Natural Join
        Return a Schema that is a natural join of this schema and another.
        """
        joined_schema = Schema()
        joined_schema.columns.extend(self.columns)  # Copy existing columns

        for column in other.columns:
            if column not in self.columns:
                joined_schema.columns.append(column)  # Add unique columns

        return joined_schema

    def serialize(self) -> bytes:
        """Serialize schema to bytes for storage."""
        buffer = bytearray()
        for column in self.columns:
            name_bytes = column.get_column_name().encode()
            buffer.extend(pack("<I", len(name_bytes)))  # Column name length
            buffer.extend(name_bytes)  # Column name
            buffer.extend(pack("<I", column.get_internal_type()))  # Column type
            buffer.extend(pack("<I", column.get_max_sql_length()))  # Max size
            buffer.extend(pack("<I", 1 if column.get_column_name() == self.key else 0))  # Primary key flag
        return bytes(buffer)

    @staticmethod
    def deserialize(byte_data: bytes) -> "Schema":
        """
        Reconstructs the table metadata (column names/types/PK) from bytes.
        """
        schema = Schema()
        buffer = memoryview(byte_data)
        offset = 0

        while offset < len(buffer):
            name_len = unpack_from("<I", buffer, offset)[0]
            offset += 4

            name = buffer[offset:offset + name_len].tobytes().decode("utf-8")
            offset += name_len

            col_type = unpack_from("<I", buffer, offset)[0]
            offset += 4

            max_size = unpack_from("<I", buffer, offset)[0]
            offset += 4

            is_key = unpack_from("<I", buffer, offset)[0]
            offset += 4

            if col_type == 1:
                column = TypeInt(name)
            elif col_type == 2:
                column = TypeVarchar(name, max_size)
            else:
                raise ValueError("Invalid column type during deserialization.")

            schema.columns.append(column)
            if is_key == 1:
                schema.key = name

        return schema


    def __repr__(self) -> str:
        """String representation of the schema."""
        column_descriptions = []
        for column in self.columns:
            col_desc = f"{column.get_column_name()} {column.get_external_name()}"
            if self.key and column.get_column_name() == self.key:
                col_desc += " PRIMARY KEY"
            column_descriptions.append(col_desc)
        return f"[{', '.join(column_descriptions)}]"