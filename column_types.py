# struct module allows conversion between Python values and packed binary data
from struct import pack, unpack_from
from typing import Any

class TypeInt:
    """
    Represents an integer column type
    """
    def __init__(self, column_name: str):
        # name of column in db table
        self.column_name = column_name

    def get_column_name(self) -> str:
        return self.column_name

    # an int in PostgreSQL is 4 bytes and (most other database systems)
    def get_max_size_bytes(self) -> int:
        return 4  # Integer size

    def get_max_sql_length(self) -> int:
        """For fixed-width INT, return storage width in bytes (4)."""
        return 4
    
    def get_external_name(self) -> str:
        return "int"

    def get_internal_type(self) -> int:
        return 1 

    # buffer is a memoryview object
    # allows efficient byte-level access without copying data.
    # "<i" → signed int, explicitly little-endian, standard size, and no padding.
    def read_value(self, buffer: memoryview) -> int:
        """Reads an integer from the buffer."""
        if len(buffer) < 4:
            raise ValueError("Not enough bytes to read int")
        return unpack_from("<i", buffer, 0)[0]

    def write_value(self, value: Any, buffer: bytearray) -> None:
        """Writes an integer to the buffer."""
        if not isinstance(value, int):
            raise TypeError("Expected an integer value")
        if not (-2**31 <= value < 2**31):
            raise ValueError("int out of 32-bit range")
        buffer.extend(pack("<i", value))

    def __eq__(self, other: Any) -> bool:
        """Checks equality based on column name."""
        return isinstance(other, TypeInt) and self.column_name == other.column_name

    def __repr__(self) -> str:
        """String representation for debugging."""
        return f"TypeInt(column_name='{self.column_name}')"


class TypeVarchar:
    """
    Represents a variable-length string column type.
    Think VARCHAR(50)
    """
    def __init__(self, column_name: str, max_size: int):
        self.column_name = column_name
        self.max_size = max_size

    def get_column_name(self) -> str:
        return self.column_name

    # An extra 4 bytes to store the actual string length (common in databases like PostgreSQL).
    def get_max_size_bytes(self) -> int:
        return self.max_size + 4

    def get_max_sql_length(self) -> int:
        return self.max_size

    def get_external_name(self) -> str:
        return f"varchar({self.max_size})"

    def get_internal_type(self) -> int:
        return 2  

    # "<I" → unsigned int, explicit little-endian, standard size, no alignment/padding.
    def read_value(self, buffer: memoryview) -> str:
        if len(buffer) < 4:
            raise ValueError("Not enough bytes to read length")
        strlen = unpack_from("<I", buffer, 0)[0]
        if strlen > self.max_size:
            raise ValueError(f"Length {strlen} exceeds max {self.max_size}")
        if 4 + strlen > len(buffer):
            raise ValueError("Buffer does not contain full string payload")
        return buffer[4:4+strlen].tobytes().decode("utf-8")

    def write_value(self, value: Any, buffer: bytearray) -> None:
        if not isinstance(value, str):
            raise TypeError("Expected a string value")
        encoded = value.encode("utf-8")
        if len(encoded) > self.max_size:
            raise ValueError(f"String exceeds max length {self.max_size}")
        buffer.extend(pack("<I", len(encoded)))
        buffer.extend(encoded)

    def __eq__(self, other: Any) -> bool:
        return isinstance(other, TypeVarchar) and self.column_name == other.column_name and self.max_size == other.max_size

    def __repr__(self) -> str:
        return f"TypeVarchar(column_name='{self.column_name}', max_size={self.max_size})"