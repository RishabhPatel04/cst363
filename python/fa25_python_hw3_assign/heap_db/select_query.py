from __future__ import annotations
from typing import Optional, Iterable
from .table import Table
from .db_tuple import DbTuple
from .query_conditions import Condition 

class SelectQuery:
    def __init__(self, col_names: Optional[Iterable[str]], condition: Condition):
        """
        col_names: list of column names to project (None means all columns)
        condition: a Condition instance for filtering rows.
        """
        if col_names is None:
            self.col_names = None
        else:
            self.col_names = [str(name) for name in col_names]
        
        self.condition = condition

    def select(self, table: Table) -> Table:
        src_schema = table.get_schema()

        
        # Determine the output schema:
        # - If no column list was provided, use the source schema (select *).
        # - Otherwise, build a projection schema in that column order.
        
        if self.col_names is None:
            proj_schema = src_schema
        else:
            proj_schema = src_schema.projection(self.col_names)
    
        result = Table(proj_schema)
        needs_projection = proj_schema is not src_schema

        for row in table:
            if self.condition.evaluate(row):  # Condition takes only the row
                # Insert either the original row (schemas identical) or a projected copy.
                insert_row = row.projection(proj_schema) if needs_projection else row
                result.insert(insert_row)

        return result


    @staticmethod
    def natural_join(table1: Table, table2: Table) -> Table:
        s1 = table1.get_schema()
        s2 = table2.get_schema()
        joined_schema = s1.natural_join(s2)
        result = Table(joined_schema)

        # === TODO 1: Determine join column names (use ONLY public Schema API) ===
        # Build column name lists and intersect them to get natural-join columns.
        names1 = [s1.get_name(i) for i in range(s1.size())]
        names2 = [s2.get_name(i) for i in range(s2.size())]
        join_cols = list(set(names1) & set(names2))

        # === TODO 2: Special case — NO common columns => Cartesian product ===
        if not join_cols:
            joined_schema.key = None
            for r1 in table1:
                for r2 in table2:
                    joined_row = DbTuple.join_db_tuple(joined_schema, r1, r2)
                    result.insert(joined_row)
            return result

        # === TODO 3: Nested-loop natural join on ALL common columns ===
        for r1 in table1:
            for r2 in table2:
                if all(r1.get_by_name(c) == r2.get_by_name(c) for c in join_cols):
                    joined_row = DbTuple.join_db_tuple(joined_schema, r1, r2)
                    result.insert(joined_row)

        # === TODO 4 (optional, extra credit): PK fast path ===
        # If s2.get_key() is in join_cols, you can look up the matching right row in O(n)
        # per left row using: table2.lookup_by_key(r1.get_by_name(s2.get_key())).
        # This is an optimization; not required for correctness.

        # Finally:
        return result


    def __str__(self):
        proj_columns = ",".join(self.col_names) if self.col_names is not None else "*"
        return f"select {proj_columns} where {self.condition}"
