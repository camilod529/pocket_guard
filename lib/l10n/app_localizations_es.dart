// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Administrador de Dinero';

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String get calendar => 'Calendario';

  @override
  String get more => 'Más';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get addAccount => 'Agregar Cuenta';

  @override
  String get accounts => 'Cuentas';

  @override
  String get category_income_salary => 'Salario';

  @override
  String get category_income_freelance => 'Freelance';

  @override
  String get category_expense_food_dining => 'Comida';

  @override
  String get category_expense_transportation => 'Transporte';

  @override
  String get category_expense_rent => 'Alquiler';

  @override
  String get category_transfer => 'Transferencia';

  @override
  String get error_db_constraint_violation => 'Se violó una restricción de la base de datos. Puede ser una entrada duplicada o una referencia no válida.';

  @override
  String get error_db_closed => 'La conexión con la base de datos no está disponible. Por favor, reinicia la aplicación.';

  @override
  String get error_db_operation_failed => 'La operación en la base de datos falló. Inténtalo de nuevo.';

  @override
  String error_db_operation_failed_operation(String operation) {
    return 'No se pudo $operation. Inténtalo de nuevo.';
  }

  @override
  String get error_data_not_found => 'Los datos solicitados no fueron encontrados.';

  @override
  String error_data_not_found_entity(String entity) {
    return 'La $entity solicitada no fue encontrada.';
  }

  @override
  String get error_foreign_key_violation => 'No se puede completar la operación porque hace referencia a datos que ya no existen.';

  @override
  String error_foreign_key_violation_table(String table) {
    return 'No se puede completar la operación porque hace referencia a una $table que ya no existe.';
  }

  @override
  String get error_storage_full => 'El almacenamiento del dispositivo está lleno. Libera espacio e inténtalo de nuevo.';

  @override
  String get error_unique_constraint_violation => 'Este registro ya existe.';

  @override
  String error_unique_constraint_violation_field(String field) {
    return 'Ya existe un registro con este $field.';
  }

  @override
  String get error_unknown_data => 'Algo salió mal con la operación de datos. Inténtalo de nuevo.';
}
