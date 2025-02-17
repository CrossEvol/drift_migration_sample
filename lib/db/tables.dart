import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  // added in schema version 2, got a default in version 4
  TextColumn get name => text().withDefault(const Constant('name'))();

  // IntColumn get createdAt => integer().nullable()();

  /*
  *  Unhandled Exception: SqliteException(1):
  *  while executing, Cannot add a column with non-constant default, SQL logic error (code 1)
  * */
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
