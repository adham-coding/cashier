import "package:cashier/model/config.dart";
import "package:cashier/model/history.dart";
import "package:cashier/model/person.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class CashierDB {
  static const _dbName = "cashier.db";
  static const _dbVersion = 1;

  static const configTable = "config";
  static const personTable = "person";
  static const historyTable = "history";

  static const configId = "id";
  static const configCurrency = "currency";

  static const personId = "id";
  static const personName = "name";
  static const personPhone = "phone";
  static const personBalance = "balance";

  static const historyId = "id";
  static const personHistoryId = "personId";
  static const historyOutgoing = "outgoing";
  static const historyIncome = "income";
  static const historyTimestamp = "timestamp";
  static const historyCurrency = "currency";
  static const historyComment = "comment";

  // DB SETTINGS
  CashierDB._privateConstructor();

  static final CashierDB instance = CashierDB._privateConstructor();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON;");
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
      CREATE TABLE $configTable (
        $configId INTEGER PRIMARY KEY AUTOINCREMENT,
        $configCurrency CHARACTER(3) NOT NULL
      );
    """);
    await db.execute("""
      CREATE TABLE $personTable (
        $personId INTEGER PRIMARY KEY AUTOINCREMENT,
        $personName VARCHAR(255) NOT NULL,
        $personPhone CHARACTER(20) NOT NULL,
        $personBalance TEXT NOT NULL
      );
    """);
    await db.execute("""
      CREATE TABLE $historyTable (
        $historyId INTEGER PRIMARY KEY AUTOINCREMENT,
        $personHistoryId INTEGER NOT NULL,
        $historyOutgoing INTEGER NOT NULL,
        $historyIncome INTEGER NOT NULL,
        $historyTimestamp INTEGER NOT NULL,
        $historyCurrency CHARACTER(3) NOT NULL,
        $historyComment CHARACTER(3) NOT NULL,
        FOREIGN KEY ($personHistoryId) REFERENCES $personTable ($personId)                  
        ON DELETE CASCADE ON UPDATE NO ACTION
      );
    """);
    await db.execute("""
      INSERT INTO $configTable ($configCurrency) VALUES ('UZS');
    """);
  }

  Future<int> editConfig(Config config) async {
    final Database db = await instance.database;

    return await db.update(
      configTable,
      config.toJSON(),
      where: "$configId = 1",
    );
  }

  Future<Config> getConfig() async {
    final Database db = await instance.database;

    List<Map<String, dynamic>> config = await db.query(configTable);

    return Config.fromJSON(config[0]);
  }

  // PERSON QUERIES
  Future<int> createPerson(Person person) async {
    final Database db = await instance.database;

    return await db.insert(
      personTable,
      person.toJSON(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> editPerson(Person person) async {
    final Database db = await instance.database;

    return await db.update(
      personTable,
      person.toJSON(),
      where: "$personId = ${person.id}",
    );
  }

  Future<int> deletePerson(int id) async {
    final Database db = await instance.database;

    return await db.delete(personTable, where: "$personId = $id");
  }

  Future<List<Person>> searchPersons(
    String searchQuery,
    String currency,
  ) async {
    final Database db = await instance.database;

    List<Map<String, dynamic>> persons = await db.query(
      personTable,
      where: """
          $personName LIKE '%$searchQuery%'
          AND $personBalance LIKE '%$currency%'
          """,
      orderBy: "$personName ASC",
    );

    return List.generate(persons.length, (i) => Person.fromJSON(persons[i]));
  }

  Future<List<Person>> getPersons(String currency) async {
    final Database db = await instance.database;

    List<Map<String, dynamic>> persons = await db.query(
      personTable,
      orderBy: "$personName ASC",
      where: "$personBalance LIKE '%$currency%'",
    );

    return List.generate(persons.length, (i) => Person.fromJSON(persons[i]));
  }

  // HISTORY QUERIES
  Future<int> createHistory(History history) async {
    final Database db = await instance.database;

    return await db.insert(
      historyTable,
      history.toJSON(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> editHistory(History history) async {
    final Database db = await instance.database;

    return await db.update(
      historyTable,
      history.toJSON(),
      where: "$historyId = ${history.id}",
    );
  }

  Future<int> deleteHistory(int id) async {
    final Database db = await instance.database;

    return await db.delete(historyTable, where: "$historyId = $id");
  }

  Future<List<History>> filterHistories(
    int personId,
    String currency,
    int startDate,
    int endDate,
  ) async {
    final Database db = await instance.database;

    List<Map<String, dynamic>> histories = await db.query(
      historyTable,
      orderBy: '$historyTimestamp DESC',
      where: """
      $personHistoryId == $personId
      AND $historyCurrency LIKE '%$currency%'
      AND $historyTimestamp >= $startDate
      AND $historyTimestamp <= $endDate 
      """,
    );

    return List.generate(
      histories.length,
      (i) => History.fromJSON(histories[i]),
    );
  }

  Future<List<History>> getHistories(int personId, String currency) async {
    final Database db = await instance.database;

    List<Map<String, dynamic>> histories = await db.query(
      historyTable,
      orderBy: "$historyTimestamp DESC",
      where: """
      $personHistoryId == $personId
      AND $historyCurrency LIKE '%$currency%'
      """,
    );

    return List.generate(
      histories.length,
      (i) => History.fromJSON(histories[i]),
    );
  }
}
