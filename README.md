# drift_migration_sample

# core commands
`Makefile`
```makefile
gen:
	dart run build_runner build

migrate:
	dart run drift_dev make-migrations
```

# Target
add IntColumn to store DateTime data, then copy its value into DateTimeColumn, and delete the IntColumn at last.

# Steps 
## One
`tables.dart`
```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  // added in schema version 2, got a default in version 4
  TextColumn get name => text().withDefault(const Constant('name'))();
}

```

run 
`make gen`

run 
`make migrate`

`database.dart`
```dart
@DriftDatabase(
  tables: [Users],
)
class Database extends _$Database {
  @override
  int get schemaVersion => 1;

  Database(super.connection);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        m.createAll();
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          for (var i = 1; i <= 5; i++) {
            await into(users).insert(UsersCompanion(name: Value('user$i')));
          }
        }
        if (details.hadUpgrade) {
        }
      },
    );
  }
}

```

## Two
`tables.dart`
```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  // added in schema version 2, got a default in version 4
  TextColumn get name => text().withDefault(const Constant('name'))();

  IntColumn get createdAt => integer().nullable()();
}

```

run
`make gen`

run
`make migrate`

`database.dart`
```dart

@DriftDatabase(
  tables: [Users],
)
class Database extends _$Database {
  @override
  int get schemaVersion => 2;

  Database(super.connection);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        m.createAll();
      },
      onUpgrade: stepByStep(from1To2: (m, schema) async {
        // Write your migrations here
        m.addColumn(schema.users, schema.users.createdAt);
      }),
      beforeOpen: (details) async {
        if (details.wasCreated) {
          for (var i = 1; i <= 5; i++) {
            await into(users).insert(UsersCompanion(name: Value('user$i')));
          }
        }
        if (details.hadUpgrade) {
          if (details.versionBefore == 1 && details.versionNow == 2) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement(
                "UPDATE users SET created_at = strftime('%s', datetime('now'))");

            await customStatement('PRAGMA foreign_keys = ON');
          }
        }
      },
    );
  }
}

```

## Three
`tables.dart`
```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  // added in schema version 2, got a default in version 4
  TextColumn get name => text().withDefault(const Constant('name'))();

  IntColumn get createdAt => integer().nullable()();

  DateTimeColumn get updatedAt => dateTime().nullable()();
}

```

run
`make gen`

run
`make migrate`

`database.dart`
```dart

@DriftDatabase(
  tables: [Users],
)
class Database extends _$Database {
  @override
  int get schemaVersion => 3;

  Database(super.connection);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        m.createAll();
      },
      onUpgrade: stepByStep(from1To2: (m, schema) async {
        // Write your migrations here
        m.addColumn(schema.users, schema.users.createdAt);
      }, from2To3: (Migrator m, Schema3 schema) async {
        m.addColumn(schema.users, schema.users.updatedAt);
      }),
      beforeOpen: (details) async {
        if (details.wasCreated) {
          for (var i = 1; i <= 5; i++) {
            await into(users).insert(UsersCompanion(name: Value('user$i')));
          }
        }
        if (details.hadUpgrade) {
          if (details.versionBefore == 1 && details.versionNow == 2) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement(
                "UPDATE users SET created_at = strftime('%s', datetime('now'))");

            await customStatement('PRAGMA foreign_keys = ON');
          }

          if (details.versionBefore == 2 && details.versionNow == 3) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement(
                "UPDATE users SET updated_at = datetime(created_at, 'unixepoch', 'localtime')");

            await customStatement('PRAGMA foreign_keys = ON');
          }
        }
      },
    );
  }
}

```

## Four
`tables.dart`
```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();

  // added in schema version 2, got a default in version 4
  TextColumn get name => text().withDefault(const Constant('name'))();

  DateTimeColumn get updatedAt => dateTime().nullable()();
}

```

run
`make gen`

run
`make migrate`

`database.dart`
```dart

@DriftDatabase(
  tables: [Users],
)
class Database extends _$Database {
  @override
  int get schemaVersion => 4;

  Database(super.connection);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        m.createAll();
      },
      onUpgrade: stepByStep(from1To2: (m, schema) async {
        // Write your migrations here
        m.addColumn(schema.users, schema.users.createdAt);
      }, from2To3: (Migrator m, Schema3 schema) async {
        m.addColumn(schema.users, schema.users.updatedAt);
      }, from3To4: (Migrator m, Schema4 schema) async {
        m.dropColumn(schema.users, "created_at");
      }),
      beforeOpen: (details) async {
        if (details.wasCreated) {
          for (var i = 1; i <= 5; i++) {
            await into(users).insert(UsersCompanion(name: Value('user$i')));
          }
        }
        if (details.hadUpgrade) {
          if (details.versionBefore == 1 && details.versionNow == 2) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement(
                "UPDATE users SET created_at = strftime('%s', datetime('now'))");

            await customStatement('PRAGMA foreign_keys = ON');
          }

          if (details.versionBefore == 2 && details.versionNow == 3) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement(
                "UPDATE users SET updated_at = datetime(created_at, 'unixepoch', 'localtime')");

            await customStatement('PRAGMA foreign_keys = ON');
          }

          if (details.versionBefore == 3 && details.versionNow == 4) {
            await customStatement('PRAGMA foreign_keys = OFF');

            await customStatement('PRAGMA foreign_keys = ON');
          }
        }
      },
    );
  }
}


```
