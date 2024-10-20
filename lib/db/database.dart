import 'package:drift/drift.dart';
import 'package:drift/internal/versioned_schema.dart';
import 'package:drift_dev/api/migrations.dart';
import 'package:drift_migration_sample/db/database.steps.dart';

import 'tables.dart';

part 'database.g.dart';

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
        // For Flutter apps, this should be wrapped in an if (kDebugMode) as
        // suggested here: https://drift.simonbinder.eu/Migrations/tests/#verifying-a-database-schema-at-runtime

        // TODO : I do not know how to let this pass
        // await validateDatabaseSchema();
      },
    );
  }
}
